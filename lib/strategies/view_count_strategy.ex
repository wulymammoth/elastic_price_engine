defmodule ElasticPriceEngine.ViewCountStrategy do
  @moduledoc false

  defstruct views: 0, price: Money.new(0, :USD)

  defimpl ElasticPriceEngine.PricingStrategy do
    @dollar Money.new(100, :USD)

    def amount(%{price: amount}), do: amount

    def count(%{views: count}), do: count

    def increment(state = %{views: views, price: price}) do
      views = views + 1
      price = if rem(views, 3) == 0, do: Money.add(price, @dollar), else: price
      %{state | views: views, price: price}
    end

    def decrement(state = %{views: 0}), do: state

    def decrement(state = %{views: views, price: price}) do
      price = if rem(views, 3) == 0, do: Money.subtract(price, @dollar), else: price
      %{state | views: views - 1, price: price}
    end
  end
end
