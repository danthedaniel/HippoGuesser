defmodule MtpoWeb.RoomChannel do
  use Phoenix.Channel
  alias Mtpo.{Rounds, Users, Repo}
  alias Mtpo.Rounds.Round
  alias MtpoWeb.Endpoint
  require Logger

  def join("room:lobby", _message, socket) do
    {
      :ok,
      full_state(),
      socket
    }
  end

  def full_state do
    round = Rounds.current_round! |> Repo.preload(guesses: :user)
    %{
      state: round.state,
      correct: round.correct_value,
      guesses: Enum.map(round.guesses, &guess_payload/1)
    }
  end

  def broadcast_state(%Round{state: :in_progress} = round) do
    Endpoint.broadcast "room:lobby", "state", %{state: round.state, guesses: []}
  end
  def broadcast_state(%Round{state: :closed} = round) do
    Endpoint.broadcast "room:lobby", "state", %{
      state: round.state,
      winner: Rounds.winning_name(round),
      correct: round.correct_value
    }
  end
  def broadcast_state(%Round{state: :completed} = round) do
    Endpoint.broadcast "room:lobby", "state", %{state: round.state}
  end

  def broadcast_guess(guess) do
    Endpoint.broadcast "room:lobby", "guess", guess |> Repo.preload(:user) |> guess_payload
  end

  def guess_payload(guess) do
    %{
      user: guess.user.name,
      value: guess.value,
      user_score: Users.num_correct_guesses(guess.user)
    }
  end
end
