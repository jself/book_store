defmodule BookStoreWeb.StoreLive.Details do
  use BookStoreWeb, :live_view
  alias BookStore.Store
  alias BookStore.CartService
  alias BookStoreWeb.Live.Helpers.CartHelper

  def mount(params, _session, socket) do
    book_id = params["book_id"]
    book = Store.get_book_with_authors!(book_id)

    socket = CartHelper.assign_cart_data(socket)

    in_cart = if socket.assigns.current_user,
      do: CartHelper.item_in_cart?(socket.assigns.current_user.id, book.id),
      else: false

    in_library = CartHelper.item_in_library?(socket.assigns.library_book_ids, book.id)

    socket = assign(socket, book: book, in_cart: in_cart, in_library: in_library)

    socket =
      if socket.assigns.current_user &&
         (params["highlight"] == book_id || params["highlight"] == "#{book.id}") &&
         !in_cart do
        auto_add_to_cart(socket, book.id)
      else
        socket
      end

    {:ok, socket}
  end

  # Helper to add a book to cart automatically (after login)
  defp auto_add_to_cart(socket, book_id) do
    if socket.assigns.current_user do
      CartService.add_to_cart(socket.assigns.current_user.id, book_id)
      assign(socket, in_cart: true) |> put_flash(:info, "Book added to your cart")
    else
      socket
    end
  end

  def handle_event("add_to_cart", %{"book_id" => book_id}, socket) do
    case CartHelper.handle_add_to_cart(socket, String.to_integer(book_id)) do
      {:ok, updated_socket} ->
        {:noreply, assign(updated_socket, in_cart: true)}

      {:auth_required, socket, book_id} ->
        return_to = ~p"/book/#{book_id}?highlight=#{book_id}"

        {:noreply,
         socket
         |> put_flash(:info, "Please log in to add items to your cart")
         |> redirect(to: ~p"/users/log_in?#{%{return_to: return_to}}")}
    end
  end

  def handle_event("remove_from_cart", %{"book_id" => book_id}, socket) do
    {:ok, updated_socket} = CartHelper.handle_remove_from_cart(socket, String.to_integer(book_id))
    {:noreply, assign(updated_socket, in_cart: false)}
  end

  def handle_info({:cart_changed}, socket) do
    # First update cart items in the socket and send update to cart component
    socket = CartHelper.handle_cart_changes(socket)

    # Then update in_cart status for book details page
    book_id = socket.assigns.book.id
    in_cart = if socket.assigns.current_user do
      CartHelper.item_in_cart?(socket.assigns.current_user.id, book_id)
    else
      false
    end

    {:noreply, assign(socket, in_cart: in_cart)}
  end
end
