defmodule Mtpo.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :token, :string, null: false
      add :user_id, references(:users), null: false
      add :expires_on, :naive_datetime, null: false

      timestamps()
    end

    create unique_index(:sessions, [:token])
  end
end
