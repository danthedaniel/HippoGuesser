defmodule MtpoBot.Bot do
  use GenServer
  require Logger

  defmodule Config do
    defstruct server:  nil,
              port:    nil,
              pass:    nil,
              nick:    nil,
              user:    nil,
              name:    nil,
              channel: nil,
              client:  nil

    def from_params(params) when is_map(params) do
      Enum.reduce(params, %Config{}, fn {k, v}, acc ->
        case Map.has_key?(acc, k) do
          true  -> Map.put(acc, k, v)
          false -> acc
        end
      end)
    end
  end

  alias ExIrc.Client
  alias IrcMessage
  alias Mtpo.{Users, Guesses, Rounds}
  alias Mtpo.Users.User
  alias Mtpo.Guesses.Guess
  alias MtpoWeb.RoomChannel

  def start_link(%{:nick => nick} = params) when is_map(params) do
    config = Config.from_params(params)
    GenServer.start_link(__MODULE__, [config], name: String.to_atom(nick))
  end

  def init([config]) do
    # Start the client and handler processes, the ExIRC supervisor is
    # automatically started when your app runs.
    {:ok, client} = ExIrc.start_link!()

    # Register the event handler with ExIRC
    Client.add_handler client, self()

    # Connect and logon to a server, join a channel and send a simple message
    Logger.debug "Connecting to #{config.server}:#{config.port}"
    Client.connect_ssl! client, config.server, config.port

    {:ok, %Config{config | :client => client}}
  end

  def handle_info({:connected, server, port}, config) do
    Logger.debug "Connected to #{server}:#{port}"
    Logger.debug "Logging to #{server}:#{port} as #{config.nick}"
    Client.logon config.client, config.pass, config.nick, config.user, config.name

    {:noreply, config}
  end
  def handle_info(:logged_in, config) do
    Logger.debug "Logged in to #{config.server}:#{config.port}"
    Logger.debug "Joining #{config.channel}"

    # Request tags capability
    Client.cmd config.client, "CAP REQ :twitch.tv/tags"

    Client.join config.client, config.channel
    {:noreply, config}
  end
  def handle_info(:disconnected, config) do
    Logger.debug "Disconnected from #{config.server}:#{config.port}"
    {:stop, :normal, config}
  end
  def handle_info({:joined, channel}, config) do
    Logger.debug "Joined #{channel}"
    {:noreply, config}
  end
  # Twitch chat event handler
  def handle_info({:unrecognized, "@badges" <> tags, %IrcMessage{} = message}, config) do
    badges = "@badges" <> tags
    |> make_map(";", "=")
    |> Map.get("@badges")
    |> make_map(",", "/")
    message = parse_msg(message.args |> List.first)

    try do
      parse_command(message, badges, config)
    rescue
      e -> Logger.error "Error in command processing: #{inspect(e)}"
    end
    {:noreply, config}
  end
  def handle_info({:winner, round}, config) do
    alert = case Rounds.winning_name(round) do
      nil  -> "No one guessed correctly :("
      name -> "@#{name} has guessed correctly with #{round.correct_value}! PogChamp"
    end
    Logger.debug alert
    Client.msg config.client, :privmsg, config.channel, alert
    {:noreply, config}
  end
  def handle_info(_msg, config) do
    {:noreply, config}
  end

  def terminate(_, state) do
    # Quit the channel and close the underlying client connection when the
    # process is terminating
    Client.quit state.client, "Goodbye, cruel world."
    Client.stop! state.client
    :ok
  end

  @doc """
  Convert a delimited string into a map, first spliting on the pair_sep, then on
  the value_sep.

  ## Examples

      iex> make_map("a:b;c:d", ";", ":")
      %{"a" => "b", "c" => "d"}

      iex> make_map("", ";", ":")
      %{}

  """
  def make_map(str, pair_sep, value_sep) do
    String.split(str, pair_sep, trim: true)
    |> Enum.map(fn(x) -> String.split(x, value_sep) |> List.to_tuple end)
    |> Map.new
  end

  # Convert a raw message into a hash with keys for nick, channel, and text
  defp parse_msg(msg) do
    pattern = ~r/(?<nick>[^!]+)!.*?PRIVMSG #\S+ :(?<text>.*)/
    Regex.named_captures(pattern, msg)
  end

  defp parse_command(%{"nick" => nick, "text" => text}, badges, config) do
    # Set up user in database
    perm_level = perm_level_from_badges(badges)
    {:ok, user} = Users.create_or_get_user(%{name: String.downcase(nick)})
    {:ok, user} = Users.update_user(user, %{perm_level: perm_level})

    # Parse the command
    command_pattern = ~r/^!(?<name>\S+)\s?(?<args>.*)/
    command = Regex.named_captures(command_pattern, text)

    # First try to parse a raw timestamp guess
    case Guess.check_time(text) do
      {:ok, _} -> guess(user, text)
      :error   -> dispatch_command(user, config, command)
    end
  end

  # Given a command, execute the appropriate function.
  defp dispatch_command(_user, _config, nil), do: nil
  defp dispatch_command(user, config, %{"name" => name, "args" => args}) do
    Logger.info name <> " " <> args
    case {name, String.split(args, " ")} do
      {"guess", [value]}     -> guess(user, Guess.check_time(value))
      {"start", [""]}        -> state_change(user, "start")
      {"stop", [""]}         -> state_change(user, "stop")
      {"winner", [correct]}  -> state_change(user, "winner", [correct])
      {"w", [correct]}       -> state_change(user, "winner", [correct])
      {"hipposite", [""]}    -> hipposite(config)
      {"leaderboard", [""]}  -> leaderboard(config)
      {"leaderboards", [""]} -> leaderboard(config)
      {"gg", [""]}           -> gg(user, config)
      {"perm", [target]}     -> whitelist(config, user, format_name(target))
      {"unperm", [target]}   -> unwhitelist(config, user, format_name(target))
      {"permitted", [""]}    -> show_whitelist(config, user)
      _                      -> nil
    end
  end

  # Execute the leaderboard command.
  defp leaderboard(config) do
    msg = Users.leaderboard(3)
    |> Stream.with_index
    |> Enum.map(fn ({%{name: name, count: count}, i}) ->
      "\##{i + 1}. @#{name} - #{count} wins"
    end)
    |> Enum.join(", ")

    case msg do
      "" -> Client.msg config.client, :privmsg, config.channel, "Nothing yet..."
      msg -> Client.msg config.client, :privmsg, config.channel, msg
    end
  end

  # Execute the hipposite command.
  defp hipposite(config) do
    url = "https://mtpo.teaearlgraycold.me/"
    Client.msg config.client, :privmsg, config.channel, url
  end

  # Execute the gg command.
  defp gg(user, config) do
    if Users.can_state_change(user) do
      Rounds.close_all
      RoomChannel.broadcast_state(Rounds.current_round!)
      Client.msg config.client, :privmsg, config.channel, "no re"
    end
  end

  # Execute the guess command.
  defp guess(user, {:ok, time}) do
    Guesses.create_guess(%{
      "round_id" => Rounds.current_round!.id,
      "user_id"  => user.id,
      "value"    => time
    })
  end

  # Execute state change commands.
  defp state_change(user, command, args \\ []) do
    state = case command do
      "start"  -> :in_progress
      "stop"   -> :completed
      "winner" -> :closed
    end

    if Users.can_state_change(user) do
      round = Rounds.current_round!
      case round.state do
        :closed      -> Rounds.create_round
        :in_progress -> Rounds.update_round(round, %{state: state})
        :completed   ->
          with {:ok, correct} <- Enum.at(args, 0) |> Guess.check_time do
            Rounds.update_round(round, %{state: state, correct_value: correct})
          end
        _ -> nil
      end
    end
  end

  # Add a target user to the round controlling whitelist.
  defp whitelist(config, %User{perm_level: :admin}, {:ok, name}) do
    {:ok, target} = Users.create_or_get_user(%{name: String.downcase(name)})
    {:ok, _} = Users.update_user(target, %{whitelisted: true})
    Client.msg config.client, :privmsg, config.channel, "User added."
  end

  # Remove a target user from the round controlling whitelist.
  defp unwhitelist(config, %User{perm_level: :admin}, {:ok, name}) do
    {:ok, target} = Users.create_or_get_user(%{name: String.downcase(name)})
    {:ok, _} = Users.update_user(target, %{whitelisted: false})
    Client.msg config.client, :privmsg, config.channel, "User removed."
  end

  # Display all whitelisted user in the channel's chat.
  defp show_whitelist(config, user) do
    if Users.can_state_change(user) do
      list = Users.whitelist |> Enum.map(&(&1.name)) |> Enum.join(", ")
      Client.msg config.client, :privmsg, config.channel, "Permitted: #{list}"
    end
  end

  defp perm_level_from_badges(badges) do
    case badges do
      %{"moderator" => _}   -> :mod
      %{"broadcaster" => _} -> :admin
      %{"banned" => _}      -> :banned
      _                     -> :user
    end
  end

  defp format_name(name) do
    case Regex.named_captures(~r/^@?(?<name>\S+$)/, name) do
      %{"name" => name} -> {:ok, name}
      nil -> :error
    end
  end
end
