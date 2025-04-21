defmodule BookStore.Repo.Migrations.AddTimestampsToLibraryItems do
  use Ecto.Migration

  def change do
    alter table(:library_items) do
      add :inserted_at, :utc_datetime, null: false
      add :updated_at, :utc_datetime, null: false
    end
  end
end
