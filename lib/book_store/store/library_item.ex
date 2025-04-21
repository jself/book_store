defmodule BookStore.Store.LibraryItem do

  use Ecto.Schema
  import Ecto.Changeset
  alias BookStore.Accounts.User
  alias BookStore.Store.Book
  alias BookStore.Store.Order

  schema "library_items" do
    belongs_to :user, User
    belongs_to :book, Book
    belongs_to :order, Order

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(library_item, attrs) do
    library_item
    |> cast(attrs, [:user_id, :book_id, :order_id])
    |> validate_required([:user_id, :book_id, :order_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:book_id)
    |> foreign_key_constraint(:order_id)
  end
end
