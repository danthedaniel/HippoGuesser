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
    tag_map = make_map("@badges" <> tags, ";", "=")

    if String.length(tag_map["@badges"]) > 1 do
      badges = make_map(tag_map["@badges"], ",", "/")
      message = parse_msg(message.args |> List.first)

      try do
        parse_command(message, badges, config)
      rescue
        e -> Logger.error "Error in command processing: #{inspect(e)}"
      end
    end
    {:noreply, config}
  end
  def handle_info({:winner, round}, config) do
    name = Rounds.winning_name(round)
    alert = if is_nil(name) do
      "No one guessed correctly :("
    else
      "@#{name} has guessed correctly with #{round.correct_value}! ConcernFroge"
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

  """
  def make_map(str, pair_sep, value_sep) do
    String.split(str, pair_sep)
    |> Enum.map(fn(x) -> String.split(x, value_sep) |> List.to_tuple end)
    |> Map.new
  end

  @doc """
  Convert a raw message into a hash with keys for nick, channel, and text
  """
  def parse_msg(msg) do
    pattern = ~r/(?<nick>[^!]+)!.*?PRIVMSG #(?<channel>\S+) :(?<text>.*)/
    Regex.named_captures(pattern, msg)
  end

  def parse_command(msg, badges, config) do
    %{
      "nick" => nick,
      "text" => text,
      "channel" => _
    } = msg
    # Set up user in database
    perm_level = perm_level_from_badges(badges)
    {:ok, user} = Users.create_or_get_user(%{name: String.downcase(nick)})
    {:ok, user} = Users.update_user(user, %{perm_level: perm_level})

    # Parse the command
    command_pattern = ~r/^!(?<name>\S+)\s?(?<args>.*)/
    command = Regex.named_captures(command_pattern, text)

    if not is_nil(command) do
      Logger.info msg
      args = command["args"] |> String.split(" ")
      case command["name"] do
        "guess"  ->
          if Enum.count(args) > 0 do
            guess(user, args |> List.first)
          end
        "start"     -> state_change(user, "start", args)
        "stop"      -> state_change(user, "stop", args)
        "winner"    -> state_change(user, "winner", args)
        "w"         -> state_change(user, "winner", args)
        "hipposite" ->
          url = "https://mtpo.teaearlgraycold.me/"
          Client.msg config.client, :privmsg, config.channel, url
        "gg"        ->
          if Users.can_state_change(user) do
            Rounds.close_all
            Client.msg config.client, :privmsg, config.channel, "no re"
          end
      end
    end
  end

  def perm_level_from_badges(badges) do
    case badges do
      %{"moderator" => _}   -> :mod
      %{"broadcaster" => _} -> :admin
      %{"banned" => _}      -> :banned
      _                     -> :user
    end
  end

  @doc """
  Execute the guess command.
  """
  def guess(user, value) do
    time = check_time(value)
    if not is_nil(time) do
      # Enter the guess into the database
      round = Rounds.current_round!
      changeset = %{
        "round_id" => round.id,
        "user_id" => user.id,
        "value" => time
      }
      Guesses.create_guess(changeset)
    end
  end

  @doc """
  Parse and validate a time-formatted string. Return nil if invalid.

  ## Examples

      iex> check_time("0:40.99")
      "0:40.99"

      iex> check_time("40.99")
      "0:40.99"

      iex> check_time("foo")
      nil
  """
  def check_time(value) do
    time_pattern = ~r/(?<minutes>\d+)?:?(?<seconds>\d\d.\d\d)/
    time_captures = Regex.named_captures(time_pattern, value)

    if not is_nil(time_captures) do
      if String.length(time_captures["minutes"]) == 0 do
        "0:" <> time_captures["seconds"]
      else
        time_captures["minutes"] <> ":" <> time_captures["seconds"]
      end
    end
  end

  @doc """
  Execute state change commands.
  """
  def state_change(user, state, args) do
    round = Rounds.current_round!
    state = case state do
      "start"  -> :in_progress
      "stop"   -> :completed
      "winner" -> :closed
    end

    if Users.can_state_change(user) do
      case round.state do
        :closed -> Rounds.create_round
        :in_progress -> Rounds.update_round(round, %{state: state})
        :completed ->
          correct = Enum.at(args, 0) |> check_time
          if not is_nil(correct) do
            Rounds.update_round(round, %{state: state, correct_value: correct})
          end
      end
    end
  end
end
