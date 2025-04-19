defmodule BookStore.StoreFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BookStore.Store` context.
  """

  @doc """
  Generate a book.
  """
  def book_fixture(attrs \\ %{}) do
    {:ok, book} =
      attrs
      |> Enum.into(%{
        description: "some description",
        isbn: 42,
        title: "some title"
      })
      |> BookStore.Store.create_book()

    book
  end

  @doc """
  Generate a author.
  """
  def author_fixture(attrs \\ %{}) do
    {:ok, author} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> BookStore.Store.create_author()

    author
  end

  @doc """
  Generate a author_book.
  """
  def author_book_fixture(attrs \\ %{}) do
    {:ok, author_book} =
      attrs
      |> Enum.into(%{

      })
      |> BookStore.Store.create_author_book()

    author_book
  end
end
