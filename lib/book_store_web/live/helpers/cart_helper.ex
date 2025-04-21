defmodule BookStoreWeb.Live.Helpers.CartHelper do
  @moduledoc """
  Helper functions for cart-related operations in LiveView components.
  """

  import Phoenix.Component, only: [assign: 2, assign_new: 3]
  import Phoenix.LiveView, only: [connected?: 1, send_update: 2]
  alias BookStore.CartService
  alias BookStore.Store

  def assign_cart_data(socket) do
    current_user = socket.assigns[:current_user]

    socket
    |> assign_new(:cart_items, fn -> get_cart_items(current_user) end)
    |> assign_library_book_ids()
    |> subscribe_to_cart_changes()
  end

  def assign_library_book_ids(socket) do
    current_user = socket.assigns[:current_user]

    library_book_ids = if current_user do
      Store.books_in_library(current_user.id)
    else
      []
    end

    assign(socket, library_book_ids: library_book_ids)
  end

  def subscribe_to_cart_changes(socket) do
    if connected?(socket) && socket.assigns[:current_user] do
      Phoenix.PubSub.subscribe(BookStore.PubSub, "cart:#{socket.assigns.current_user.id}")
    end

    socket
  end

  def handle_cart_changes(socket) do
    current_user = socket.assigns[:current_user]

    # Update the cart items in the LiveView's assigns
    cart_items = get_cart_items(current_user)
    socket = assign(socket, cart_items: cart_items)

    # Send update to the cart component to refresh its state
    if connected?(socket) && current_user do
      send_update(BookStoreWeb.Components.Cart, %{
        id: "cart",  # ID matches the one in app.html.heex
        current_user: current_user
      })
    end

    socket
  end

  def item_in_cart?(user_id, book_id) when is_integer(user_id) and is_integer(book_id) do
    cart_items = CartService.get_cart_items(user_id)
    Enum.any?(cart_items, fn item -> item.book_id == book_id end)
  end
  def item_in_cart?(_user_id, _book_id), do: false

  def item_in_library?(library_book_ids, book_id) when is_integer(book_id) do
    book_id in library_book_ids
  end
  def item_in_library?(_library_book_ids, _book_id), do: false

  def get_cart_items(nil), do: []
  def get_cart_items(user), do: CartService.get_cart_items(user.id)

  def update_books_with_cart_info(books, current_user, library_book_ids \\ []) do
    if current_user do
      cart_items = CartService.get_cart_items(current_user.id)
      cart_book_ids = Enum.map(cart_items, & &1.book_id)

      Enum.map(books, fn book ->
        book
        |> Map.put(:in_cart, book.id in cart_book_ids)
        |> Map.put(:in_library, book.id in library_book_ids)
      end)
    else
      Enum.map(books, fn book ->
        book
        |> Map.put(:in_cart, false)
        |> Map.put(:in_library, false)
      end)
    end
  end

  def handle_add_to_cart(socket, book_id) do
    if socket.assigns.current_user do
      # User is logged in, add to cart
      CartService.add_to_cart(socket.assigns.current_user.id, book_id)

      {:ok, Phoenix.LiveView.put_flash(socket, :info, "Book added to your cart")}
    else
      # User is not logged in, redirect needed
      {:auth_required, socket, book_id}
    end
  end

  def handle_remove_from_cart(socket, book_id) do
    if socket.assigns.current_user do
      CartService.remove_from_cart(socket.assigns.current_user.id, book_id)

      {:ok, Phoenix.LiveView.put_flash(socket, :info, "Book removed from your cart")}
    else
      # This case shouldn't happen with proper UI
      {:ok, socket}
    end
  end
end
