defmodule BookStore.StoreTest do
  use BookStore.DataCase

  alias BookStore.Store

  describe "books" do
    alias BookStore.Store.Book

    import BookStore.StoreFixtures

    @invalid_attrs %{description: nil, title: nil, isbn: nil}

    test "list_books/0 returns all books" do
      book = book_fixture()
      assert Store.list_books() == [book]
    end

    test "get_book!/1 returns the book with given id" do
      book = book_fixture()
      assert Store.get_book!(book.id) == book
    end

    test "create_book/1 with valid data creates a book" do
      valid_attrs = %{description: "some description", title: "some title", isbn: 42}

      assert {:ok, %Book{} = book} = Store.create_book(valid_attrs)
      assert book.description == "some description"
      assert book.title == "some title"
      assert book.isbn == 42
    end

    test "create_book/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Store.create_book(@invalid_attrs)
    end

    test "update_book/2 with valid data updates the book" do
      book = book_fixture()
      update_attrs = %{description: "some updated description", title: "some updated title", isbn: 43}

      assert {:ok, %Book{} = book} = Store.update_book(book, update_attrs)
      assert book.description == "some updated description"
      assert book.title == "some updated title"
      assert book.isbn == 43
    end

    test "update_book/2 with invalid data returns error changeset" do
      book = book_fixture()
      assert {:error, %Ecto.Changeset{}} = Store.update_book(book, @invalid_attrs)
      assert book == Store.get_book!(book.id)
    end

    test "delete_book/1 deletes the book" do
      book = book_fixture()
      assert {:ok, %Book{}} = Store.delete_book(book)
      assert_raise Ecto.NoResultsError, fn -> Store.get_book!(book.id) end
    end

    test "change_book/1 returns a book changeset" do
      book = book_fixture()
      assert %Ecto.Changeset{} = Store.change_book(book)
    end
  end

  describe "authors" do
    alias BookStore.Store.Author

    import BookStore.StoreFixtures

    @invalid_attrs %{name: nil}

    test "list_authors/0 returns all authors" do
      author = author_fixture()
      assert Store.list_authors() == [author]
    end

    test "get_author!/1 returns the author with given id" do
      author = author_fixture()
      assert Store.get_author!(author.id) == author
    end

    test "create_author/1 with valid data creates a author" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Author{} = author} = Store.create_author(valid_attrs)
      assert author.name == "some name"
    end

    test "create_author/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Store.create_author(@invalid_attrs)
    end

    test "update_author/2 with valid data updates the author" do
      author = author_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Author{} = author} = Store.update_author(author, update_attrs)
      assert author.name == "some updated name"
    end

    test "update_author/2 with invalid data returns error changeset" do
      author = author_fixture()
      assert {:error, %Ecto.Changeset{}} = Store.update_author(author, @invalid_attrs)
      assert author == Store.get_author!(author.id)
    end

    test "delete_author/1 deletes the author" do
      author = author_fixture()
      assert {:ok, %Author{}} = Store.delete_author(author)
      assert_raise Ecto.NoResultsError, fn -> Store.get_author!(author.id) end
    end

    test "change_author/1 returns a author changeset" do
      author = author_fixture()
      assert %Ecto.Changeset{} = Store.change_author(author)
    end
  end

  describe "author_books" do
    alias BookStore.Store.AuthorBook

    import BookStore.StoreFixtures

    @invalid_attrs %{}

    test "list_author_books/0 returns all author_books" do
      author_book = author_book_fixture()
      assert Store.list_author_books() == [author_book]
    end

    test "get_author_book!/1 returns the author_book with given id" do
      author_book = author_book_fixture()
      assert Store.get_author_book!(author_book.id) == author_book
    end

    test "create_author_book/1 with valid data creates a author_book" do
      valid_attrs = %{}

      assert {:ok, %AuthorBook{} = author_book} = Store.create_author_book(valid_attrs)
    end

    test "create_author_book/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Store.create_author_book(@invalid_attrs)
    end

    test "update_author_book/2 with valid data updates the author_book" do
      author_book = author_book_fixture()
      update_attrs = %{}

      assert {:ok, %AuthorBook{} = author_book} = Store.update_author_book(author_book, update_attrs)
    end

    test "update_author_book/2 with invalid data returns error changeset" do
      author_book = author_book_fixture()
      assert {:error, %Ecto.Changeset{}} = Store.update_author_book(author_book, @invalid_attrs)
      assert author_book == Store.get_author_book!(author_book.id)
    end

    test "delete_author_book/1 deletes the author_book" do
      author_book = author_book_fixture()
      assert {:ok, %AuthorBook{}} = Store.delete_author_book(author_book)
      assert_raise Ecto.NoResultsError, fn -> Store.get_author_book!(author_book.id) end
    end

    test "change_author_book/1 returns a author_book changeset" do
      author_book = author_book_fixture()
      assert %Ecto.Changeset{} = Store.change_author_book(author_book)
    end
  end
end
