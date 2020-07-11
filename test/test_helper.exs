ExUnit.start()

defmodule TestHelper do
  defmacro __using__(_opts) do
    quote do
      import ExUnit.Assertions, only: [assert: 1]

      def has(result, expectation) when is_function(expectation) do
        assert expectation.(result) == true
        result
      end

      def is(result, expectation) do
        assert result == expectation
        result
      end
    end
  end
end
