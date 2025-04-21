defmodule BookStore.Signals do
  @moduledoc """
  Handles PubSub signals for various application events.
  """

  @doc """
  Broadcast a cart change event for a specific user.
  """
  def cart_changed(user_id) do
    Phoenix.PubSub.broadcast(BookStore.PubSub, "cart:#{user_id}", {:cart_changed})
  end

  @doc """
  Subscribe to cart change events for a specific user.
  This is handled automatically by CartHelper.subscribe_to_cart_changes/1.
  """
  def subscribe_to_cart_changes(user_id) do
    Phoenix.PubSub.subscribe(BookStore.PubSub, "cart:#{user_id}")
  end
end
