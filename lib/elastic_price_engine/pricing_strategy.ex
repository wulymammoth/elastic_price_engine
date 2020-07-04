defmodule ElasticPriceEngine.PricingStrategy do
  alias ElasticPriceEngine, as: EPE

  import NimbleOptions, only: [validate: 2]

  defmacro __using__(opts) do
    quote do
      import EPE.PricingStrategyHelpers, only: [add: 3, money: 2, subtract: 3]

      defstruct unquote(fields(opts[:schema]))

      def options_schema(), do: unquote(opts[:schema])

      def validate(options), do: validate(options, __MODULE__.options_schema())
    end
  end

  defp fields(schema) do
    Enum.reduce(schema, [], fn {field, options}, fields ->
      Keyword.put(fields, field, options[:default])
    end)
  end
end
