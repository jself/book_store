defmodule BookStoreWeb.Components.Cart do
  use BookStoreWeb, :live_component
  alias BookStore.CartService
  alias BookStoreWeb.Live.Helpers.CartHelper
  import Phoenix.LiveView, only: [connected?: 1, put_flash: 3]

  def mount(socket) do
    {:ok, assign(socket, show_dropdown: false, cart_items: [])}
  end

  def update(assigns, socket) do
    cart_items = if assigns[:current_user] do
      CartService.get_cart_items(assigns.current_user.id)
    else
      []
    end

    socket = socket
      |> assign(assigns)
      |> assign(cart_items: cart_items)

    {:ok, socket}
  end

  # Handle updates sent from parent LiveView
  def handle_update(assigns, socket) do
    cart_items = if assigns[:current_user] do
      CartService.get_cart_items(assigns.current_user.id)
    else
      []
    end

    socket = socket
      |> assign(assigns)
      |> assign(cart_items: cart_items)

    {:ok, socket}
  end

  def handle_event("toggle_dropdown", _, socket) do
    {:noreply, assign(socket, show_dropdown: !socket.assigns.show_dropdown)}
  end

  def handle_event("close_dropdown", _, socket) do
    {:noreply, assign(socket, show_dropdown: false)}
  end

  def handle_event("remove_from_cart", %{"book_id" => book_id}, socket) do
    if socket.assigns.current_user do
      CartService.remove_from_cart(socket.assigns.current_user.id, String.to_integer(book_id))
      # Cart will be updated via PubSub to parent LiveView which will send updates
    end

    {:noreply, socket}
  end

  def calculate_total(cart_items) do
    Enum.reduce(cart_items, Decimal.new(0), fn item, acc ->
      Decimal.add(acc, item.book.price)
    end)
  end

  def format_price(price) do
    case price do
      nil -> "0.00"
      price when is_binary(price) -> price
      price -> Decimal.round(price, 2)
    end
  end

  def render(assigns) do
    ~H"""
    <div class="relative" id="cart-dropdown-container" phx-hook="CartHook">
      <button
        phx-click="toggle_dropdown"
        phx-target={@myself}
        class="relative p-2 text-gray-600 hover:text-gray-900 focus:outline-none"
        aria-label="Shopping Cart"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
        </svg>
        <%= if length(@cart_items) > 0 do %>
          <span class="absolute -top-1 -right-1 bg-red-500 text-white text-xs font-bold rounded-full h-5 w-5 flex items-center justify-center">
            <%= length(@cart_items) %>
          </span>
        <% end %>
      </button>

      <%= if @show_dropdown do %>
        <div class="absolute right-0 mt-2 w-72 bg-white rounded-md shadow-lg z-50 overflow-hidden" id="cart-dropdown">
          <div class="py-2 px-4 bg-gray-100 border-b border-gray-200">
            <h3 class="text-sm font-semibold">Your Cart (<%= length(@cart_items) %> items)</h3>
          </div>

          <%= if length(@cart_items) == 0 do %>
            <div class="p-4 text-center text-gray-500">
              Your cart is empty
            </div>
          <% else %>
            <div class="max-h-96 overflow-y-auto">
              <%= for item <- @cart_items do %>
                <div class="py-2 px-4 border-b border-gray-100 flex items-center">
                  <div class="h-12 w-12 flex-shrink-0 bg-gray-200 rounded">
                    <!-- Book thumbnail placeholder -->
                    <div class="h-full w-full flex items-center justify-center">
                      <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                      </svg>
                    </div>
                  </div>
                  <div class="ml-4 flex-1">
                    <h4 class="text-sm font-medium text-gray-900 truncate"><%= item.book.title %></h4>
                    <p class="text-xs text-gray-500">$<%= format_price(item.book.price) %></p>
                  </div>
                  <button
                    class="ml-2 text-red-500 hover:text-red-700"
                    phx-click="remove_from_cart"
                    phx-value-book_id={item.book_id}
                    phx-target={@myself}
                  >
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m4-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                  </button>
                </div>
              <% end %>
            </div>
            <div class="p-4 border-t border-gray-200">
              <div class="flex justify-between text-sm mb-4">
                <span class="font-medium">Total:</span>
                <span class="font-bold">$<%= format_price(calculate_total(@cart_items)) %></span>
              </div>
              <.link patch={~p"/checkout"} class="w-full bg-blue-600 hover:bg-blue-700 text-white py-2 px-4 rounded-md text-sm font-medium">
                Checkout
              </.link>
            </div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end
end
