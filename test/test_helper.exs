ExUnit.start()

defmodule TestHelper do
  defmacro __using__(_opts) do
    quote do
      import ExUnit.Assertions, only: [assert: 1]

      def is(result, expectation) do
        assert result == expectation
      end
    end
  end
end
