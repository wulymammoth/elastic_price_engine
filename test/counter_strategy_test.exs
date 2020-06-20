defmodule ElasticPriceEngine.ViewCountStrategyTest do
  use ExUnit.Case
  doctest ElasticPriceEngine.ViewCountStrategy

  alias ElasticPriceEngine.PricingStrategy, as: Strategy
  alias ElasticPriceEngine.ViewCountStrategy, as: Schema

  setup_all do
    {:ok, opts} =
      NimbleOptions.validate([decrement: 100, increment: 100, step: 3], Schema.options_schema())

    [state: struct(Schema, opts)]
  end

  describe "increment" do
    test "count", %{state: state} do
      assert state |> Strategy.increment() |> Strategy.count() == 1
      assert %{state | views: 87} |> Strategy.increment() |> Strategy.count() == 88
    end

    test "amount", %{state: state} do
      assert %{state | views: 0} |> Strategy.increment() |> Strategy.amount() == usd(0)

      assert %{state | views: 8, price: 8600} |> Strategy.increment() |> Strategy.amount() ==
               usd(87)
    end

    test "ceiling", %{state: state} do
      state =
        %{state | views: 165, price: 5400, ceiling: 5500}
        # 55
        |> Strategy.increment()
        # 56
        |> Strategy.increment()
        # 57
        |> Strategy.increment()

      assert Strategy.count(state) == 168
      assert Strategy.amount(state) == usd(55)
    end
  end

  describe "decrement" do
    test "count", %{state: state} do
      assert %{state | views: 1} |> Strategy.decrement() |> Strategy.count() == 0
      assert %{state | views: 88} |> Strategy.decrement() |> Strategy.count() == 87
      assert %{state | views: 0} |> Strategy.decrement() |> Strategy.count() == 0
    end

    test "amount", %{state: state} do
      assert %{state | views: 7, price: 200} |> Strategy.decrement() |> Strategy.amount() ==
               usd(1)

      assert %{state | views: 5, price: 200} |> Strategy.decrement() |> Strategy.amount() ==
               usd(2)

      assert %{state | views: 0, price: 0} |> Strategy.decrement() |> Strategy.amount() == usd(0)
    end

    test "floor", %{state: state} do
      state =
        %{state | floor: 100, views: 4, price: 200}
        # 3
        |> Strategy.decrement()
        # 2
        |> Strategy.decrement()
        # 1
        |> Strategy.decrement()
        # 1
        |> Strategy.decrement()

      assert Strategy.count(state) == 0
      assert Strategy.amount(state) == usd(1)
    end
  end

  defp usd(amt), do: Money.parse!(amt, :USD)
end
