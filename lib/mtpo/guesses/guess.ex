defmodule Mtpo.Guesses.Guess do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mtpo.Guesses.Guess
  alias Mtpo.Rounds


  schema "guesses" do
    field :value, :string
    belongs_to :user, Mtpo.Users.User
    belongs_to :round, Mtpo.Rounds.Round

    timestamps()
  end

  def value_regex do
    ~r/^(?<min>\d+):(?<sec>\d\d.\d\d)$/
  end

  def value_seconds(value) do
    %{
      "min" => minutes,
      "sec" => seconds
    } = Regex.named_captures(Guess.value_regex, value)
    {minutes, ""} = Float.parse(minutes)
    {seconds, ""} = Float.parse(seconds)
    minutes * 60.0 + seconds
  end

  @doc """
  Verify that associated rounds are in_progress.
  """
  def validate_round(%Ecto.Changeset{} = changeset) do
    %{changes: changes, errors: errors} = changeset
    value = Map.get(changes, :round_id)
    new = if is_nil(value) or Rounds.get_round!(value).state == :in_progress do
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
    |> validate_format(:value, Guess.value_regex)
    |> Guess.validate_round
    |> unique_constraint(:round_id, name: :guesses_user_id_round_id_index)
    |> unique_constraint(:round_id, name: :guesses_value_round_id_index)
  end
end
