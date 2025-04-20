defmodule BookStoreWeb.StoreLive.Details do
  use BookStoreWeb, :live_view
  alias BookStore.Store

  def mount(params, session, socket) do
    {:ok,
     socket
     |> assign(book: get_book(params["book_id"]))
     |> assign(in_cart: false)}
  end

  defp get_book(id) do
    Store.get_book_with_authors!(id)
  end
end
