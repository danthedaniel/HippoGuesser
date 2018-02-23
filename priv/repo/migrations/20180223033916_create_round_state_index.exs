defmodule Mtpo.Repo.Migrations.CreateRoundStateIndex do
  use Ecto.Migration

  def change do
    create index(:rounds, [:state])
  end
end
