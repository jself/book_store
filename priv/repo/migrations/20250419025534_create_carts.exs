defmodule BookStore.Repo.Migrations.CreateCarts do
  use Ecto.Migration

  def change do
    create table(:carts) do
      add :user, references(:users, on_delete: :nothing)
      add :book, references(:books, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:carts, [:user])
    create index(:carts, [:book])
  end
end
