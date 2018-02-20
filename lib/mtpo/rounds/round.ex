defmodule Mtpo.Rounds.Round do
  require Logger

  use Ecto.Schema
  import Ecto.Changeset
  alias Mtpo.Rounds.Round
  alias Mtpo.Guesses.Guess


  schema "rounds" do
    field :state, RoundState
    field :correct_value, :string
    has_many :guesses, Guess

    timestamps()
  end

  def value_regex do
    ~r/^(\d+:\d\d.\d\d)?$/
  end

  def valid_transitions do
    [
      {:in_progress, :completed},
      {:completed, :closed}
    ]
  end

  @doc """
  Verify validity of a change in the state of a round.
  """
  def validate_transition(%Ecto.Changeset{} = changeset, round) do
    %{changes: changes, errors: errors} = changeset
    value = Map.get(changes, :state)
    Logger.debug "#{round.state}, #{value}"
    valid = Enum.member?(Round.valid_transitions, {round.state, value})
    new = if is_nil(value) or is_nil(round.state) or valid do
      []
    else
      [{:state, {"state transition is not valid", [validation: :transition]}}]
    end

    case new do
      []    -> changeset
      [_|_] -> %{changeset | errors: new ++ errors, valid?: false}
    end
  end

  @doc false
  def changeset(%Round{} = round, attrs) do
    round
    |> cast(attrs, [:state, :correct_value])
    |> validate_transition(round)
    |> validate_format(:correct_value, Round.value_regex)
  end
end
