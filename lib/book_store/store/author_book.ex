defmodule BookStore.Store.AuthorBook do
  use Ecto.Schema
  import Ecto.Changeset

  schema "author_books" do
    belongs_to :author, BookStore.Store.Author
    belongs_to :book, BookStore.Store.Book

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(author_book, attrs) do
    author_book
    |> cast(attrs, [:author_id, :book_id])
    |> validate_required([:author_id, :book_id])
  end
end
