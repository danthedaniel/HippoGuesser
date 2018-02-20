defmodule Mtpo.Repo.Migrations.CreateRound do
  use Ecto.Migration

  def change do
    create table(:rounds) do
      add :state, :integer, default: 0, null: false
      add :correct_value, :string, default: "", null: false

      timestamps()
    end

  end
end
