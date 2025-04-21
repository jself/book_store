defmodule BookStore.Store.Order do
  use Ecto.Schema
  import Ecto.Changeset
  alias BookStore.Accounts.User
  alias BookStore.Store.LibraryItem

  schema "orders" do
    field :total_price, :decimal
    field :status, :string
    field :payment_method, :string
    field :payment_status, :string

    belongs_to :user, User

    has_many :library_items, LibraryItem

    timestamps(type: :utc_datetime)
  end

  def changeset(order, attrs) do
    order
    |> cast(attrs, [:total_price, :status, :payment_method, :payment_status])
    |> validate_required([:total_price, :status, :payment_method, :payment_status])
  end
end
