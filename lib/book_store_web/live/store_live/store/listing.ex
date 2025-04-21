defmodule BookStoreWeb.StoreLive.Listing do
  use BookStoreWeb, :live_view
  alias BookStore.Store
  alias BookStore.CartService
  alias BookStoreWeb.Live.Helpers.CartHelper

  embed_templates "./components/*"

  @impl true
  def mount(params, session, socket) do
    # Then use CartHelper which now uses current_user from assigns
    socket = CartHelper.assign_cart_data(socket)

    socket =
      socket
      |> assign(search: nil)
      |> assign(page: 1)
      |> assign(page_size: 6)
      |> assign_books()

    # If there's a highlight parameter and the user is logged in, add the book to cart
    socket =
      if socket.assigns.current_user && params["highlight"] do
        book_id = String.to_integer(params["highlight"])
        case handle_auto_add_to_cart(socket, book_id) do
          {:ok, updated_socket} ->
            # Redirect to remove the highlight parameter from URL
            updated_socket
            |> push_patch(to: ~p"/", replace: true)
          _ -> socket
        end
      else
        socket
      end

    {:ok, socket}
  end

  # Helper to add a book to cart automatically (after login)
  defp handle_auto_add_to_cart(socket, book_id) do
    if socket.assigns.current_user do
      CartService.add_to_cart(socket.assigns.current_user.id, book_id)
      {:ok, assign_books(socket) |> put_flash(:info, "Book added to your cart")}
    else
      {:error, socket}
    end
  end

  defp assign_books(socket) do
    search = socket.assigns.search
    page = socket.assigns.page
    page_size = socket.assigns.page_size
    filtered = get_filtered_books(search, page, page_size)

    books = CartHelper.update_books_with_cart_info(
      filtered.books,
      socket.assigns.current_user,
      socket.assigns[:library_book_ids] || []
    )

    socket
    |> assign(books: books)
    |> assign(pagination: filtered)
  end

  defp get_filtered_books(search, page, page_size) do
    Store.filter_books([page: page, search: search, page_size: page_size])
  end

  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    {:noreply, socket
      |> assign(search: search)
      |> assign(page: 1)
      |> assign_books()
    }
  end

  @impl true
  def handle_event("reset-search", _params, socket) do
    {:noreply, socket
      |> assign(search: nil)
      |> assign(page: 1)
      |> assign_books()
    }
  end

  @impl true
  def handle_event("next_page", _params, socket) do
    {:noreply, socket
      |> assign(page: socket.assigns.page + 1)
      |> assign_books()
    }
  end

  @impl true
  def handle_event("prev_page", _params, socket) do
    {:noreply, socket
      |> assign(page: socket.assigns.page - 1)
      |> assign_books()
    }
  end

  @impl true
  def handle_event("change_page_size", %{"page_size" => page_size}, socket) do
    page_size = String.to_integer(page_size)

    {:noreply, socket
      |> assign(page_size: page_size)
      |> assign(page: 1) # Reset to first page when changing page size
      |> assign_books()
    }
  end

  @impl true
  def handle_event("add_to_cart", %{"book_id" => book_id}, socket) do
    case CartHelper.handle_add_to_cart(socket, String.to_integer(book_id)) do
      {:ok, updated_socket} ->
        {:noreply, assign_books(updated_socket)}

      {:auth_required, socket, book_id} ->
        return_to = ~p"/?#{%{highlight: book_id}}"

        {:noreply,
         socket
         |> put_flash(:info, "Please log in to add items to your cart")
         |> redirect(to: ~p"/users/log_in?#{%{return_to: return_to}}")}
    end
  end

  @impl true
  def handle_event("remove_from_cart", %{"book_id" => book_id}, socket) do
    {:ok, updated_socket} = CartHelper.handle_remove_from_cart(socket, String.to_integer(book_id))
    {:noreply, assign_books(updated_socket)}
  end

  @impl true
  def handle_info({:cart_changed}, socket) do
    # First update cart items in the socket
    socket = CartHelper.handle_cart_changes(socket)
    # Then refresh the book list with updated cart info
    {:noreply, assign_books(socket)}
  end
end
