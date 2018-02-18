defmodule Mtpo.Rounds.Round do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mtpo.Rounds.Round


  schema "round" do
    field :end_time, :naive_datetime
    field :start_time, :naive_datetime
    field :started_by, :integer
    field :state, RoundState

    timestamps()
  end

  @doc false
  def changeset(%Round{} = round, attrs) do
    round
    |> cast(attrs, [:start_time, :end_time, :state, :started_by])
    |> validate_required([:start_time, :end_time, :state, :started_by])
  end
end
