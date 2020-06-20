defmodule ElasticPriceEngine.Strategy do
  defmacro __using__(opts) do
    quote do
      def options_schema(), do: unquote(opts[:schema])
    end
  end
end
