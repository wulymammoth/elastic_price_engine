defmodule ElasticPriceEngine.PricingStrategy do
  alias ElasticPriceEngine, as: EPE

  defmacro __using__(opts) do
    quote do
      import EPE.PricingStrategyHelpers, only: [add: 3, money: 2, subtract: 3]

      def options_schema(), do: unquote(opts[:schema])

      defstruct unquote(fields(opts[:schema]))
    end
  end

  defp fields(schema) do
    Enum.reduce(schema, [], fn {field, options}, fields ->
      Keyword.put(fields, field, options[:default])
    end)
  end
end
