defmodule BookStore.Repo.Migrations.AddBookPrice do
  use Ecto.Migration

  def change do
    alter table(:books) do
      add :price, :decimal
    end
  end
end
