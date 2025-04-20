defmodule BookStoreWeb.StoreLive.Listing do
  use BookStoreWeb, :live_view
  alias BookStore.Store
  embed_templates "./components/*"

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(search: nil)
     |> assign(page: 1)
     |> assign(search: nil)
     |> assign(page_size: 6)
     |> assign_books()
    }
  end

  defp assign_books(socket) do
    search = socket.assigns.search
    page = socket.assigns.page
    page_size = socket.assigns.page_size
    filtered = get_filtered_books(search, page, page_size)

    socket
    |> assign(books: filtered.books)
    |> assign(pagination: filtered)
  end

  defp get_filtered_books(search, page, page_size) do
    Store.filter_books([page: page, search: search, page_size: page_size])
  end

  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    {:noreply, socket
      |> assign(search: search)
      |> assign_books()
    }
  end

  @impl true
  def handle_event("reset-search", _params, socket) do
    {:noreply, socket
      |> assign(search: nil)
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
end
