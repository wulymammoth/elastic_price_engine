defmodule ElasticPriceEngine.Strategy do
  defmacro __using__(opts) do
    quote do
      def options_schema(), do: unquote(opts[:schema])
    end
  end

  defmodule Helpers do
    defmacro __using__(_) do
      quote do
        defdelegate money(price, currency), to: Money, as: :new

        def add(price, inc, currency) do
          [price, delta] = [money(price, currency), money(inc, currency)]
          price |> Money.add(delta) |> Map.get(:amount)
        end

        def subtract(price, dec, currency) do
          [price, delta] = [money(price, currency), money(dec, currency)]
          price |> Money.subtract(delta) |> Map.get(:amount)
        end
      end
    end
  end
end
