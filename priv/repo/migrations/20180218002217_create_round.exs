defmodule Mtpo.Repo.Migrations.CreateRound do
  use Ecto.Migration

  def change do
    create table(:round) do
      add :start_time, :naive_datetime
      add :end_time, :naive_datetime
      add :state, :integer
      add :started_by, :integer

      timestamps()
    end

  end
end
