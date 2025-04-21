defmodule BookStore.Repo.Migrations.AddOrder do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :user_id, references(:users, on_delete: :nothing)
      add :total_price, :decimal
      add :status, :string
      add :payment_method, :string
      add :payment_status, :string
    end
  end
end
