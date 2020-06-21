defmodule ElasticPriceEngine.ViewCountStrategyTest do
  use ExUnit.Case, async: true
  doctest ElasticPriceEngine.ViewCountStrategy

  alias ElasticPriceEngine.Reducer
  alias ElasticPriceEngine.ViewCountStrategy, as: Schema

  setup_all do
    {:ok, opts} =
      NimbleOptions.validate([decrement: 100, increment: 100, step: 3], Schema.options_schema())

    [state: struct(Schema, opts)]
  end

  describe "increment" do
    test "count", %{state: state} do
      assert state |> Reducer.increment() |> Reducer.count() == 1
      assert %{state | views: 87} |> Reducer.increment() |> Reducer.count() == 88
    end

    test "amount", %{state: state} do
      assert %{state | views: 0} |> Reducer.increment() |> Reducer.amount() == usd(0)

      assert %{state | views: 8, price: 8600} |> Reducer.increment() |> Reducer.amount() ==
               usd(87)
    end

    test "ceiling", %{state: state} do
      state =
        %{state | views: 165, price: 5400, ceiling: 5500}
        # 55
        |> Reducer.increment()
        # 56
        |> Reducer.increment()
        # 57
        |> Reducer.increment()

      assert Reducer.count(state) == 168
      assert Reducer.amount(state) == usd(55)
    end
  end

  describe "decrement" do
    test "count", %{state: state} do
      assert %{state | views: 1} |> Reducer.decrement() |> Reducer.count() == 0
      assert %{state | views: 88} |> Reducer.decrement() |> Reducer.count() == 87
      assert %{state | views: 0} |> Reducer.decrement() |> Reducer.count() == 0
    end

    test "amount", %{state: state} do
      assert %{state | views: 7, price: 200} |> Reducer.decrement() |> Reducer.amount() ==
               usd(1)

      assert %{state | views: 5, price: 200} |> Reducer.decrement() |> Reducer.amount() ==
               usd(2)

      assert %{state | views: 0, price: 0} |> Reducer.decrement() |> Reducer.amount() == usd(0)
    end

    test "floor", %{state: state} do
      state =
        %{state | floor: 100, views: 4, price: 200}
        # 3
        |> Reducer.decrement()
        # 2
        |> Reducer.decrement()
        # 1
        |> Reducer.decrement()
        # 1
        |> Reducer.decrement()

      assert Reducer.count(state) == 0
      assert Reducer.amount(state) == usd(1)
    end
  end

  defp usd(amt), do: Money.parse!(amt, :USD)
end
