defmodule BookStore.CartService do
  alias BookStore.Signals
  def add_to_cart(user_id, book_id) do
    BookStore.Store.add_to_cart(user_id, book_id)
    Signals.cart_changed(user_id)
  end

  def remove_from_cart(user_id, book_id) do
    BookStore.Store.remove_from_cart(user_id, book_id)
    Signals.cart_changed(user_id)
  end

  def convert_to_order(user_id) do
    BookStore.Store.convert_to_order(user_id)
    Signals.cart_changed(user_id)
  end

  def get_cart_items(user_id) do
    BookStore.Store.get_cart_items(user_id)
  end

  def get_cart_total(user_id) do
    books = get_cart_items(user_id)
    Enum.reduce(books, 0, fn book, acc -> acc + book.price end)
  end
end
