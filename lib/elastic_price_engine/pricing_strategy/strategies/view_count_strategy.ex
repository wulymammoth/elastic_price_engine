defmodule ElasticPriceEngine.ViewCountStrategy do
  @moduledoc false

  use ElasticPriceEngine.PricingStrategy,
    schema: [
      ceiling: [type: :pos_integer],
      currency: [default: :USD, type: :atom],
      decrement: [required: true, type: :pos_integer],
      floor: [type: :pos_integer, default: 1],
      id: [type: :string, required: true],
      increment: [required: true, type: :pos_integer],
      price: [default: 0],
      step: [default: 1, type: :pos_integer],
      views: [default: 1, type: :pos_integer]
    ]

  defimpl ElasticPriceEngine.Reducer do
    def amount(%{currency: currency, price: amount}), do: money(amount, currency)

    def count(%{views: count}), do: count

    def increment(%{views: views} = state) do
      views = views + 1
      price = price_change(:increment, %{state | views: views})
      %{state | views: views, price: price}
    end

    def decrement(state = %{views: 0}), do: state

    def decrement(state = %{views: views}) do
      views = views - 1
      price = price_change(:decrement, %{state | views: views})
      %{state | views: views, price: price}
    end

    defp price_change(:increment, %{price: price, views: 0}), do: price

    defp price_change(:increment, state) do
      %{ceiling: ceiling, currency: currency, price: price, increment: inc} = state

      cond do
        is_nil(ceiling) and rem(state.views, state.step) == 0 ->
          add(price, inc, currency)

        ceiling && price < ceiling ->
          add(price, inc, currency)

        true ->
          price
      end
    end

    defp price_change(:decrement, %{floor: floor, price: price}) when price == floor, do: price

    defp price_change(:decrement, state = %{step: step, views: views})
         when rem(views, step) == 0 do
      subtract(state.price, state.decrement, state.currency)
    end

    defp price_change(:decrement, %{price: price}), do: price
  end
end
