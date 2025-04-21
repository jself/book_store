defmodule BookStore.Repo.Migrations.AddTimestampsToOrders do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :inserted_at, :utc_datetime, null: false
      add :updated_at, :utc_datetime, null: false
    end
  end
end
