defmodule MtpoWeb.RoomChannel do
  use Phoenix.Channel
  alias Mtpo.{Rounds, Users, Repo}
  require Logger

  def join("room:lobby", _message, socket) do
    {
      :ok,
      full_state(),
      socket
    }
  end

  def full_state do
    round = Rounds.current_round! |> Repo.preload(:guesses)
    %{
      state: round.state,
      correct: round.correct_value,
      # TODO: Re-write this as a query
      guesses: Enum.map(round.guesses, &guess_payload/1)
    }
  end

  def broadcast_state(round) do
    payload = case round.state do
      :in_progress -> %{state: round.state, guesses: []}
      :closed ->
        %{
          state: round.state,
          winner: Rounds.winning_name(round),
          correct: round.correct_value
        }
      _ -> %{state: round.state}
    end
    MtpoWeb.Endpoint.broadcast "room:lobby", "state", payload
  end

  def broadcast_guess(guess) do
    MtpoWeb.Endpoint.broadcast "room:lobby", "guess", guess_payload(guess)
  end

  def guess_payload(guess) do
    user = Users.get_user!(guess.user_id)
    %{
      user: user.name,
      value: guess.value,
      user_score: Users.num_correct_guesses(user)
    }
  end
end
