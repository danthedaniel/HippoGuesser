defmodule Mtpo.Sessions.Session do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mtpo.Sessions.Session


  schema "sessions" do
    field :expires_on, :naive_datetime
    field :token, :string
    belongs_to :user, Mtpo.Users.User

    timestamps()
  end

  @doc false
  def changeset(%Session{} = session, attrs) do
    session
    |> cast(attrs, [:token, :user_id, :expires_on])
    |> validate_required([:token, :user_id, :expires_on])
    |> unique_constraint(:token, name: :sessions_token_index)
  end
end
