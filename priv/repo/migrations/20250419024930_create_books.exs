defmodule BookStore.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :title, :string
      add :description, :text
      add :isbn, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
