defmodule BookStore.Repo.Migrations.AddLibrary do
  use Ecto.Migration

  def change do
    create table(:library_items) do
      add :user_id, references(:users, on_delete: :nothing)
      add :book_id, references(:books, on_delete: :nothing)
      add :order_id, references(:orders, on_delete: :nothing)
    end

    create index(:library_items, [:user_id])
    create index(:library_items, [:book_id])
  end
end
