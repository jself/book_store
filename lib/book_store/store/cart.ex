defmodule BookStore.Store.Cart do
  use Ecto.Schema
  import Ecto.Changeset

  schema "carts" do

    field :user, :id
    field :book, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(cart, attrs) do
    cart
    |> cast(attrs, [])
    |> validate_required([])
  end
end
