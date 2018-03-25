defmodule Mtpo.Guesses.Guess do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mtpo.Guesses.Guess
  alias Mtpo.Rounds

  @value_regex ~r/^(?<min>\d+)?[\.:]?(?<sec>\d\d)[:\.](?<frac>\d\d)$/

  schema "guesses" do
    field :value, :string
    belongs_to :user, Mtpo.Users.User
    belongs_to :round, Mtpo.Rounds.Round

    timestamps()
  end

  @doc """
  Parse and validate a time-formatted string.

  ## Examples

      iex> check_time("0:40.99")
      {:ok, "0:40.99"}

      iex> check_time("40.99")
      {:ok, "0:40.99"}

      iex> check_time("foo")
      :error
  """
  def check_time(value) do
    case Regex.named_captures(@value_regex, value) do
      %{"min" => "", "sec" => sec, "frac" => frac}  -> {:ok, "0:" <> sec <> "." <> frac}
      %{"min" => min, "sec" => sec, "frac" => frac} -> {:ok, min <> ":" <> sec <> "." <> frac}
      nil -> :error
    end
  end

  @doc """
  Parse a time-formatted string into a float.

  ## Examples

    iex> value_seconds("0:40.99")
    40.99
  """
  def value_seconds(value) do
    %{
      "min" => minutes,
      "sec" => seconds,
      "frac" => fraction
    } = Regex.named_captures(@value_regex, value)
    {minutes, ""} = Float.parse(minutes)
    {seconds, ""} = Float.parse(seconds <> "." <> fraction)
    minutes * 60.0 + seconds
  end

  @doc """
  Verify that associated rounds are in_progress.
  """
  def validate_round(%Ecto.Changeset{} = changeset) do
    %{changes: changes, errors: errors} = changeset
    value = Map.get(changes, :round_id)
    new = if not is_nil(value) and Rounds.get_round!(value).state == :in_progress do
      []
    else
      [{:state, {"round is not in progress", [validation: :round]}}]
    end

    case new do
      []    -> changeset
      [_|_] -> %{changeset | errors: new ++ errors, valid?: false}
    end
  end

  @doc false
  def changeset(%Guess{} = guess, attrs) do
    guess
    |> cast(attrs, [:round_id, :user_id, :value])
    |> validate_required([:round_id, :user_id, :value])
    |> validate_format(:value, @value_regex)
    |> Guess.validate_round
    |> unique_constraint(:round_id, name: :guesses_user_id_round_id_index)
    |> unique_constraint(:round_id, name: :guesses_value_round_id_index)
  end
end
