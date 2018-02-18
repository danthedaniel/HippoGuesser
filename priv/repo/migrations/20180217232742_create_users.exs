defmodule Mtpo.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :perm_level, :integer

      timestamps()
    end

  end
end
