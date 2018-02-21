defmodule Mtpo.Repo.Migrations.CreateIndices do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:name])
    create index(:users, [:perm_level])
    create unique_index(:guesses, [:user_id, :round_id])
    create unique_index(:guesses, [:value, :round_id])
  end
end
