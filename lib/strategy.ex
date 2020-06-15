defmodule ElasticPriceEngine.Strategy do
  @type state() :: %{amount: Money.t()}

  @callback increment(state()) :: state()
  @callback decrement(state()) :: state()
end
