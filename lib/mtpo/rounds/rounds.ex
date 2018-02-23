defmodule Mtpo.Rounds do
  @moduledoc """
  The Rounds context.
  """
  import Ecto.Query, warn: false
  alias Mtpo.Repo
  alias MtpoWeb.RoomChannel
  alias Mtpo.Rounds
  alias Mtpo.Rounds.Round
  alias Mtpo.Guesses.Guess

  @doc """
  Returns the list of round.

  ## Examples

      iex> list_round()
      [%Round{}, ...]

  """
  def list_round do
    Repo.all(Round)
  end

  @doc """
  Gets a single round.

  Raises `Ecto.NoResultsError` if the Round does not exist.

  ## Examples

      iex> get_round!(123)
      %Round{}

      iex> get_round!(456)
      ** (Ecto.NoResultsError)

  """
  def get_round!(id) do
    Repo.get!(Round, id)
    |> Repo.preload(:guesses)
  end

  def current_round! do
    case Round |> Ecto.Query.last |> Repo.one do
      nil ->
        {:ok, round} = Rounds.create_round
        round
      round -> round
    end
  end

  def winner(%Round{} = round) do
    if not is_nil(round.correct_value) do
      query = from g in Guess,
        join: u in assoc(g, :user),
        where: g.round_id == ^round.id and g.value == ^round.correct_value
      case Repo.one(query) |> Repo.preload(:user) do
        nil -> nil
        guess -> guess.user
      end
    else
      nil
    end
  end

  def winning_name(round) do
    case Rounds.winner(round) do
      nil -> nil
      user -> user.name
    end
  end

  @doc """
  Creates a round. Will set all previous rounds to :closed.

  ## Examples

      iex> create_round(%{field: value})
      {:ok, %Round{}}

      iex> create_round(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_round(attrs \\ %{}) do
    closed = RoundState.__enum_map__[:closed]
    from(r in Round, where: r.state != ^closed)
    |> Repo.update_all(set: [state: closed])
    # TODO: This /should/ be handled by the database as a default...
    attrs = Map.put_new(attrs, :state, :in_progress)

    case %Round{} |> Round.changeset(attrs) |> Repo.insert() do
      {:ok, round} ->
        RoomChannel.broadcast_state(round)
        {:ok, round}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Updates a round.

  ## Examples

      iex> update_round(round, %{field: new_value})
      {:ok, %Round{}}

      iex> update_round(round, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_round(%Round{} = round, attrs) do
    state_change = Map.get(attrs, :state) != round.state
    case round |> Round.changeset(attrs) |> Repo.update() do
      {:ok, round} ->
        if state_change do
          RoomChannel.broadcast_state(round)
          if round.state == :closed do
            name = String.to_atom(Application.get_env(:mtpo, :bot)[:name])
            send name, {:winner, round}
          end
        end
        {:ok, round}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Deletes a Round.

  ## Examples

      iex> delete_round(round)
      {:ok, %Round{}}

      iex> delete_round(round)
      {:error, %Ecto.Changeset{}}

  """
  def delete_round(%Round{} = round) do
    Repo.delete(round)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking round changes.

  ## Examples

      iex> change_round(round)
      %Ecto.Changeset{source: %Round{}}

  """
  def change_round(%Round{} = round) do
    Round.changeset(round, %{})
  end
end
