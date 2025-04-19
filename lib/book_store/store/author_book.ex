defmodule BookStore.Store.AuthorBook do
  use Ecto.Schema
  import Ecto.Changeset

  schema "author_books" do

    field :author, :id
    field :book, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(author_book, attrs) do
    author_book
    |> cast(attrs, [])
    |> validate_required([])
  end
end
