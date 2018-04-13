defmodule Mtpo.Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mtpo.Users.User


  schema "users" do
    field :name, :string
    field :whitelisted, :boolean
    field :perm_level, PermLevel
    has_many :guesses, Mtpo.Guesses.Guess

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :perm_level, :whitelisted])
    |> validate_required([:name, :perm_level])
    |> unique_constraint(:name)
  end
end
