defmodule ElasticPriceEngine.Strategies.CounterStrategyTest do
  use ExUnit.Case
  doctest ElasticPriceEngine.CounterStrategy

  alias ElasticPriceEngine.CounterStrategy, as: State
  import ElasticPriceEngine.CounterStrategy, only: [increment: 1, decrement: 1, count: 1]

  describe "count" do
    assert count(%State{}) == 0
  end

  describe "increment" do
    test "count" do
      assert increment(%State{}) |> Map.get(:count) == 1
      assert increment(%State{count: 87}) |> Map.get(:count) == 88
    end

    test "amount" do
      assert increment(%State{count: 0}) |> Map.get(:amount) == usd(0)
      assert increment(%State{count: 8, amount: usd(87)}) |> Map.get(:amount) == usd(88)
    end
  end

  describe "decrement" do
    test "count" do
      assert decrement(%State{count: 1}) |> count() == 0
      assert decrement(%State{count: 88}) |> count() == 87
      assert State.decrement(%State{}) |> count() == 0
    end

    test "amount" do
      assert decrement(%State{count: 7, amount: usd(2)}) |> Map.get(:amount) == usd(1)
      assert decrement(%State{count: 5, amount: usd(2)}) |> Map.get(:amount) == usd(2)
      assert decrement(%State{count: 0, amount: usd(0)}) |> Map.get(:amount) == usd(0)
    end
  end

  defp usd(amt), do: Money.parse!(amt, :USD)
end
