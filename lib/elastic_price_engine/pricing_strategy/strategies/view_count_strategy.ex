defmodule ElasticPriceEngine.ViewCountStrategy do
  @moduledoc false

  use ElasticPriceEngine.PricingStrategy,
    schema: [
      ceiling: [type: :pos_integer],
      currency: [default: :USD, type: :atom],
      decrement: [required: true, type: :pos_integer],
      floor: [type: :pos_integer, default: 0],
      increment: [required: true, type: :pos_integer],
      price: [default: 0],
      step: [default: 1, type: :pos_integer],
      views: [default: 0, type: :pos_integer]
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

    defp price_change(
           :increment,
           %{
             ceiling: ceiling,
             currency: currency,
             price: price,
             increment: inc,
             step: step,
             views: views
           }
         ) do
      if rem(views, step) == 0 and (is_nil(ceiling) || (ceiling && price < ceiling)) do
        add(price, inc, currency)
      else
        price
      end
    end

    defp price_change(:decrement, %{floor: floor, price: price}) when price == floor, do: price

    defp price_change(
           :decrement,
           %{currency: currency, decrement: dec, price: price, step: step, views: views}
         ) do
      if rem(views, step) == 0, do: subtract(price, dec, currency), else: price
    end
  end
end
