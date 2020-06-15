defmodule ElasticPriceEngine.CounterStrategy do
  @moduledoc false

  @behaviour ElasticPriceEngine.Strategy

  @dollar Money.parse!("$1", :USD)

  defstruct count: 0, amount: Money.new(0, :USD)

  def count(%{count: count}), do: count

  @impl true
  def increment(state = %{count: count, amount: amount}) do
    new_count = count + 1
    new_amount = if rem(new_count, 3) == 0, do: Money.add(amount, @dollar), else: amount
    %{state | count: new_count, amount: new_amount}
  end

  @impl true
  def decrement(state = %{count: 0}), do: state

  @impl true
  def decrement(state = %{count: count, amount: amount}) do
    new_count = count - 1
    new_amount = if rem(new_count, 3) == 0, do: Money.subtract(amount, @dollar), else: amount
    %{state | count: new_count, amount: new_amount}
  end
end
