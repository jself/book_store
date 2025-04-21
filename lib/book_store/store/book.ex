defmodule BookStore.Store.Book do
  use Ecto.Schema
  import Ecto.Changeset
  alias BookStore.Store.LibraryItem
  alias BookStore.Store.Cart
  alias BookStore.Store.Author
  alias BookStore.Store.AuthorBook

  schema "books" do
    field :description, :string
    field :title, :string
    field :price, :decimal
    many_to_many :authors, Author, join_through: AuthorBook

    has_many :carts, Cart
    has_many :library_items, LibraryItem

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:title, :description, :price])
    |> validate_required([:title, :description, :price])
  end
end
