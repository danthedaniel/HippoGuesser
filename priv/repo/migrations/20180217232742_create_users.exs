defmodule Mtpo.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: false
      add :perm_level, :integer, default: 0, null: false

      timestamps()
    end

  end
end
