defmodule Mtpo.Repo.Migrations.AddWhitelist do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :whitelisted, :boolean, default: false, null: false
    end
  end
end
