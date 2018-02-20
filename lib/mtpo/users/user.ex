defmodule Mtpo.Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mtpo.Users.User


  schema "users" do
    field :name, :string
    field :perm_level, PermLevel
    has_many :guesses, Mtpo.Guesses.Guess

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :perm_level])
    |> validate_required([:name, :perm_level])
    |> unique_constraint(:name)
  end
end
