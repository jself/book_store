defmodule BookStore.Store do
  @moduledoc """
  The Store context.
  """

  import Ecto.Query, warn: false
  alias BookStore.Repo

  alias BookStore.Store.Book
  alias BookStore.Store.Order
  alias BookStore.Store.LibraryItem

  @doc """
  Returns the list of books.

  ## Examples

      iex> list_books()
      [%Book{}, ...]

  """
  def list_books do
    Repo.all(Book)
  end

  @doc """
  Searches for books by title.
  SQLite doesn't support ILIKE, so we use LIKE with lower() for case-insensitive search.

  ## Examples

      iex> search_books_by_title("harry")
      [%Book{title: "Harry Potter"}, ...]

  """
  def search_books_by_title(search_term) when is_binary(search_term) do
    search_pattern = "%#{String.replace(search_term, "%", "\\%")}%"

    from(b in Book,
      where: like(fragment("lower(?)", b.title), fragment("lower(?)", ^search_pattern))
    )
  end

  @doc """
  Searches for books by author name.
  Returns a query that finds books with authors whose names match the search term.

  ## Examples

      iex> search_books_by_author("tolkien")
      [%Book{title: "The Lord of the Rings"}, ...]

  """
  def search_books_by_author(search_term) when is_binary(search_term) do
    search_pattern = "%#{String.replace(search_term, "%", "\\%")}%"

    from(b in Book,
      join: ab in BookStore.Store.AuthorBook, on: ab.book_id == b.id,
      join: a in BookStore.Store.Author, on: a.id == ab.author_id,
      where: like(fragment("lower(?)", a.name), fragment("lower(?)", ^search_pattern)),
      distinct: true
    )
  end

  @doc """
  Searches for books by title or author name.
  Returns a query that finds books where either the title or any of its authors match the search term.

  ## Examples

      iex> search_books("tolkien")
      [%Book{title: "The Lord of the Rings"}, ...]

  """
  def search_books(search_term) when is_binary(search_term) do
    title_query = search_books_by_title(search_term)
    author_query = search_books_by_author(search_term)

    from(b in Book,
      where: b.id in subquery(
        from b in title_query, select: b.id
      ) or b.id in subquery(
        from b in author_query, select: b.id
      )
    )
  end

  @doc """
  Filters books with optional search by title or author and pagination.

  ## Options
    * `:search` - Optional search term to filter books by title or author (case-insensitive)
    * `:page_size` - Number of items per page (default: 6)
    * `:page` - Page number to fetch (default: 1)

  """
  def filter_books(opts \\ []) do
    search = Keyword.get(opts, :search)
    page_size = Keyword.get(opts, :page_size, 6)
    page = Keyword.get(opts, :page, 1)

    offset = (page - 1) * page_size

    # Build query based on search term
    query =
      if search && search != "" do
        search_books(search)
      else
        Book
      end

    # Get total count for pagination info
    count_query = from(b in query, select: count(b.id))
    total_count = Repo.one(count_query)

    # Build paginated query
    books_query =
      from b in query,
        limit: ^page_size,
        offset: ^offset,
        order_by: [asc: b.title]

    books = Repo.all(books_query) |> Repo.preload(:authors)

    # Calculate pagination metadata
    page_start = offset + 1
    page_end = min(offset + page_size, total_count)

    # If no results, adjust page start/end to show 0-0
    {page_start, page_end} =
      if total_count == 0, do: {0, 0}, else: {page_start, page_end}

    %{
      books: books,
      total_count: total_count,
      page_number: page,
      page_size: page_size,
      has_next_page: page_end < total_count,
      has_prev_page: page > 1,
      page_start: page_start,
      page_end: page_end
    }
  end

  @doc """
  Returns the list of books with authors preloaded.

  ## Examples

      iex> list_books_with_authors()
      [%Book{authors: [%Author{}, ...]}, ...]

  """
  def list_books_with_authors do
    Repo.all(Book)
    |> Repo.preload(:authors)
  end

  @doc """
  Gets a single book.

  Raises `Ecto.NoResultsError` if the Book does not exist.

  ## Examples

      iex> get_book!(123)
      %Book{}

      iex> get_book!(456)
      ** (Ecto.NoResultsError)

  """
  def get_book!(id), do: Repo.get!(Book, id)

  @doc """
  Gets a single book with authors preloaded.

  Raises `Ecto.NoResultsError` if the Book does not exist.

  ## Examples

      iex> get_book_with_authors!(123)
      %Book{authors: [%Author{}, ...]}

      iex> get_book_with_authors!(456)
      ** (Ecto.NoResultsError)

  """
  def get_book_with_authors!(id) do
    Repo.get!(Book, id)
    |> Repo.preload(:authors)
  end

  @doc """
  Creates a book.

  ## Examples

      iex> create_book(%{field: value})
      {:ok, %Book{}}

      iex> create_book(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_book(attrs \\ %{}) do
    %Book{}
    |> Book.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a book.

  ## Examples

      iex> update_book(book, %{field: new_value})
      {:ok, %Book{}}

      iex> update_book(book, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_book(%Book{} = book, attrs) do
    book
    |> Book.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a book.

  ## Examples

      iex> delete_book(book)
      {:ok, %Book{}}

      iex> delete_book(book)
      {:error, %Ecto.Changeset{}}

  """
  def delete_book(%Book{} = book) do
    Repo.delete(book)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking book changes.

  ## Examples

      iex> change_book(book)
      %Ecto.Changeset{data: %Book{}}

  """
  def change_book(%Book{} = book, attrs \\ %{}) do
    Book.changeset(book, attrs)
  end

  alias BookStore.Store.Author

  @doc """
  Returns the list of authors.

  ## Examples

      iex> list_authors()
      [%Author{}, ...]

  """
  def list_authors do
    Repo.all(Author)
  end

  @doc """
  Gets a single author.

  Raises `Ecto.NoResultsError` if the Author does not exist.

  ## Examples

      iex> get_author!(123)
      %Author{}

      iex> get_author!(456)
      ** (Ecto.NoResultsError)

  """
  def get_author!(id), do: Repo.get!(Author, id)

  @doc """
  Creates a author.

  ## Examples

      iex> create_author(%{field: value})
      {:ok, %Author{}}

      iex> create_author(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_author(attrs \\ %{}) do
    %Author{}
    |> Author.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a author.

  ## Examples

      iex> update_author(author, %{field: new_value})
      {:ok, %Author{}}

      iex> update_author(author, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_author(%Author{} = author, attrs) do
    author
    |> Author.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a author.

  ## Examples

      iex> delete_author(author)
      {:ok, %Author{}}

      iex> delete_author(author)
      {:error, %Ecto.Changeset{}}

  """
  def delete_author(%Author{} = author) do
    Repo.delete(author)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking author changes.

  ## Examples

      iex> change_author(author)
      %Ecto.Changeset{data: %Author{}}

  """
  def change_author(%Author{} = author, attrs \\ %{}) do
    Author.changeset(author, attrs)
  end

  alias BookStore.Store.AuthorBook

  @doc """
  Returns the list of author_books.

  ## Examples

      iex> list_author_books()
      [%AuthorBook{}, ...]

  """
  def list_author_books do
    Repo.all(AuthorBook)
  end

  @doc """
  Gets a single author_book.

  Raises `Ecto.NoResultsError` if the Author book does not exist.

  ## Examples

      iex> get_author_book!(123)
      %AuthorBook{}

      iex> get_author_book!(456)
      ** (Ecto.NoResultsError)

  """
  def get_author_book!(id), do: Repo.get!(AuthorBook, id)

  @doc """
  Creates a author_book.

  ## Examples

      iex> create_author_book(%{field: value})
      {:ok, %AuthorBook{}}

      iex> create_author_book(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_author_book(attrs \\ %{}) do
    %AuthorBook{}
    |> AuthorBook.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a author_book.

  ## Examples

      iex> update_author_book(author_book, %{field: new_value})
      {:ok, %AuthorBook{}}

      iex> update_author_book(author_book, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_author_book(%AuthorBook{} = author_book, attrs) do
    author_book
    |> AuthorBook.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a author_book.

  ## Examples

      iex> delete_author_book(author_book)
      {:ok, %AuthorBook{}}

      iex> delete_author_book(author_book)
      {:error, %Ecto.Changeset{}}

  """
  def delete_author_book(%AuthorBook{} = author_book) do
    Repo.delete(author_book)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking author_book changes.

  ## Examples

      iex> change_author_book(author_book)
      %Ecto.Changeset{data: %AuthorBook{}}

  """
  def change_author_book(%AuthorBook{} = author_book, attrs \\ %{}) do
    AuthorBook.changeset(author_book, attrs)
  end

  alias BookStore.Store.Cart

  @doc """
  Returns the list of carts.

  ## Examples

      iex> list_carts()
      [%Cart{}, ...]

  """
  def list_carts do
    Repo.all(Cart)
  end

  @doc """
  Gets a single cart.

  Raises `Ecto.NoResultsError` if the Cart does not exist.

  ## Examples

      iex> get_cart!(123)
      %Cart{}

      iex> get_cart!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cart!(id), do: Repo.get!(Cart, id)

  @doc """
  Creates a cart.

  ## Examples

      iex> create_cart(%{field: value})
      {:ok, %Cart{}}

      iex> create_cart(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cart(attrs \\ %{}) do
    %Cart{}
    |> Cart.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cart.

  ## Examples

      iex> update_cart(cart, %{field: new_value})
      {:ok, %Cart{}}

      iex> update_cart(cart, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cart(%Cart{} = cart, attrs) do
    cart
    |> Cart.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a cart.

  ## Examples

      iex> delete_cart(cart)
      {:ok, %Cart{}}

      iex> delete_cart(cart)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cart(%Cart{} = cart) do
    Repo.delete(cart)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cart changes.

  ## Examples

      iex> change_cart(cart)
      %Ecto.Changeset{data: %Cart{}}

  """
  def change_cart(%Cart{} = cart, attrs \\ %{}) do
    Cart.changeset(cart, attrs)
  end

  @doc """
  Converts a cart to an order.
  Adds library items for books in the cart.
  Sends a confirmation email with PDF attachments.
  """
  def convert_to_order(user_id) do
    result = Repo.transaction(fn ->
      # Get cart items
      cart_items = get_cart_items(user_id)
      total_price = Enum.reduce(cart_items, Decimal.new(0), fn cart_item, acc -> Decimal.add(acc, cart_item.book.price) end)

      # Create order
      order = create_order(user_id, total_price, "pending", "cash", "pending")

      # Add library items for each cart item
      for cart_item <- cart_items do
        create_library_item(order, cart_item, user_id)
      end

      # Delete cart items
      delete_cart_items(user_id)

      order
    end)

    # Send confirmation email if the transaction was successful
    case result do
      {:ok, order} ->
        user = BookStore.Accounts.get_user!(user_id)
        BookStore.Email.send_purchase_confirmation(order, user)

      _ ->
        result
    end
  end

  defp delete_cart_items(user_id) do
    from(c in Cart, where: c.user_id == ^user_id)
    |> Repo.delete_all()
  end

  @doc """
  Gets cart items for a user with books preloaded.

  ## Examples

      iex> get_cart_items(user_id)
      [%Cart{book: %Book{}}, ...]

  """
  def get_cart_items(user_id) do
    from(c in Cart, where: c.user_id == ^user_id)
    |> Repo.all()
    |> Repo.preload(:book)
  end

  defp create_order(user_id, price, status, payment_method, payment_status) do
    case %Order{user_id: user_id, total_price: price, status: status, payment_method: payment_method, payment_status: payment_status}
    |> Order.changeset(%{})
    |> Repo.insert() do
      {:ok, order} -> order
      error -> error
    end
  end

  defp create_library_item(order, cart_item, user_id) do
    %LibraryItem{order_id: order.id, book_id: cart_item.book_id, user_id: user_id}
    |> LibraryItem.changeset(%{})
    |> Repo.insert()
  end

  @doc """
  Adds a book to the user's cart.

  ## Examples

      iex> add_to_cart(user_id, book_id)
      {:ok, %Cart{}}

  """
  def add_to_cart(user_id, book_id) do
    # Check if the cart item already exists
    existing_cart_item =
      from(c in Cart, where: c.user_id == ^user_id and c.book_id == ^book_id)
      |> Repo.one()

    if existing_cart_item do
      {:ok, existing_cart_item}
    else
      create_cart(%{user_id: user_id, book_id: book_id})
    end
  end

  @doc """
  Removes a book from the user's cart.

  ## Examples

      iex> remove_from_cart(user_id, book_id)
      {:ok, %Cart{}}

  """
  def remove_from_cart(user_id, book_id) do
    cart_item =
      from(c in Cart, where: c.user_id == ^user_id and c.book_id == ^book_id)
      |> Repo.one()

    if cart_item do
      delete_cart(cart_item)
    else
      {:error, :not_found}
    end
  end

  @doc """
  Returns a list of book IDs that are in the user's library.

  ## Examples

      iex> books_in_library(user_id)
      [1, 2, 3, ...]

  """
  def books_in_library(user_id) when is_integer(user_id) do
    from(li in LibraryItem,
      where: li.user_id == ^user_id,
      select: li.book_id)
    |> Repo.all()
  end

  @doc """
  Gets library items for a specific order with books preloaded.

  ## Examples

      iex> get_library_items_for_order(order_id)
      [%LibraryItem{book: %Book{}}, ...]

  """
  def get_library_items_for_order(order_id) do
    from(li in LibraryItem, where: li.order_id == ^order_id)
    |> Repo.all()
    |> Repo.preload(:book)
  end
end
