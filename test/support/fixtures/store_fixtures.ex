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
        title: "some title",
        price: "19.99"
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
    book = attrs[:book] || book_fixture()
    author = attrs[:author] || author_fixture()

    {:ok, author_book} =
      attrs
      |> Enum.into(%{
        book_id: book.id,
        author_id: author.id
      })
      |> BookStore.Store.create_author_book()

    author_book
  end

  @doc """
  Generate a cart.
  """
  def cart_fixture(attrs \\ %{}) do
    book = attrs[:book] || book_fixture()

    # Create a user for the cart
    {:ok, user} =
      BookStore.Accounts.register_user(%{
        email: "user#{System.unique_integer()}@example.com",
        password: "hello world!"
      })

    {:ok, cart} =
      attrs
      |> Enum.into(%{
        user_id: user.id,
        book_id: book.id
      })
      |> BookStore.Store.create_cart()

    cart
  end
end
