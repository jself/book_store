defmodule BookStore.Store.Cart do
  use Ecto.Schema
  import Ecto.Changeset

  schema "carts" do
    belongs_to :user, BookStore.Accounts.User, foreign_key: :user_id
    belongs_to :book, BookStore.Store.Book, foreign_key: :book_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(cart, attrs) do
    cart
    |> cast(attrs, [:user_id, :book_id])
    |> validate_required([:user_id, :book_id])
  end
end
