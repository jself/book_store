defmodule BookStore.Repo.Migrations.CreateAuthorBooks do
  use Ecto.Migration

  def change do
    create table(:author_books) do
      add :author, references(:Author, on_delete: :nothing)
      add :book, references(:Book, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:author_books, [:author])
    create index(:author_books, [:book])
  end
end
