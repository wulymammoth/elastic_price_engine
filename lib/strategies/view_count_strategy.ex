defmodule ElasticPriceEngine.ViewCountStrategy do
  @moduledoc false

  use ElasticPriceEngine.Strategy,
    schema: [
      ceiling: [type: :pos_integer],
      currency: [default: :USD, type: :atom],
      decrement: [required: true, type: :pos_integer],
      floor: [type: :pos_integer, default: 0],
      increment: [required: true, type: :pos_integer],
      price: [default: 0],
      step: [default: 1, type: :pos_integer]
    ]

  defstruct ceiling: nil,
            currency: :USD,
            decrement: nil,
            floor: 0,
            increment: nil,
            price: 0,
            step: 1,
            views: 0

  defimpl ElasticPriceEngine.PricingStrategy do
    use ElasticPriceEngine.Strategy.Helpers

    def amount(%{currency: currency, price: amount}), do: money(amount, currency)

    def count(%{views: count}), do: count

    def increment(%{views: views} = state) do
      views = views + 1
      price = price_delta(:+, %{state | views: views})
      %{state | views: views, price: price}
    end

    def decrement(state = %{views: 0}), do: state

    def decrement(state = %{views: views}) do
      views = views - 1
      price = price_delta(:-, %{state | views: views})
      %{state | views: views, price: price}
    end

    defp price_delta(:+, %{price: price, views: 0}), do: price

    defp price_delta(
           :+,
           %{
             ceiling: ceiling,
             currency: currency,
             price: price,
             increment: inc,
             step: step,
             views: views
           }
         ) do
      if (rem(views, step) == 0 and is_nil(ceiling)) || (ceiling && price < ceiling) do
        add(price, inc, currency)
      else
        price
      end
    end

    defp price_delta(:-, %{floor: floor, price: price}) when price == floor, do: price

    defp price_delta(
           :-,
           %{currency: currency, decrement: dec, price: price, step: step, views: views}
         ) do
           if rem(views, step) == 0, do: subtract(price, dec, currency), else: price
    end
  end
end
