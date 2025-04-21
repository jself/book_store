defmodule BookStoreWeb.StoreLive.Checkout do
  use BookStoreWeb, :live_view
  alias BookStore.CartService
  alias BookStoreWeb.Live.Helpers.CartHelper
  alias BookStoreWeb.Components.Cart

  def mount(_params, _session, socket) do
    socket = CartHelper.assign_cart_data(socket)

    # Redirect to home if cart is empty or user is not logged in
    socket =
      cond do
        socket.assigns.current_user == nil ->
          socket
          |> put_flash(:error, "Please log in to checkout")
          |> push_patch(to: ~p"/users/log_in?#{%{return_to: "/checkout"}}")

        Enum.empty?(socket.assigns.cart_items) ->
          socket
          |> put_flash(:error, "Your cart is empty")
          |> push_patch(to: ~p"/")

        true ->
          total = Cart.calculate_total(socket.assigns.cart_items)
          assign(socket, total: total)
      end

    {:ok, socket}
  end

  def handle_event("place_order", _params, socket) do
    CartService.convert_to_order(socket.assigns.current_user.id)

    {:noreply,
      socket
      |> put_flash(:info, "Order placed successfully!")
      |> push_navigate(to: ~p"/")}
  end

  def handle_event("remove_from_cart", %{"book_id" => book_id}, socket) do
    {:ok, updated_socket} = CartHelper.handle_remove_from_cart(socket, String.to_integer(book_id))

    # Check if cart becomes empty after removal
    if Enum.empty?(updated_socket.assigns.cart_items) do
      {:noreply,
        updated_socket
        |> put_flash(:info, "Your cart is now empty")
        |> push_navigate(to: ~p"/")}
    else
      total = Cart.calculate_total(updated_socket.assigns.cart_items)
      {:noreply, assign(updated_socket, total: total)}
    end
  end

  def handle_info({:cart_changed}, socket) do
    # Update cart items and handle potential empty cart
    socket = CartHelper.handle_cart_changes(socket)

    socket =
      if Enum.empty?(socket.assigns.cart_items) do
        socket
        |> put_flash(:info, "Your cart is now empty")
        |> push_navigate(to: ~p"/")
      else
        total = Cart.calculate_total(socket.assigns.cart_items)
        assign(socket, total: total)
      end

    {:noreply, socket}
  end
end
