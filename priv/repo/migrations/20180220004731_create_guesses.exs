defmodule Mtpo.Repo.Migrations.CreateGuesses do
  use Ecto.Migration

  def change do
    create table(:guesses) do
      add :round_id, references(:rounds), null: false
      add :user_id, references(:users), null: false
      add :value, :string, null: false

      timestamps()
    end

  end
end
