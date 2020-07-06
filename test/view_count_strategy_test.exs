defmodule ElasticPriceEngine.ViewCountStrategyTest do
  use ExUnit.Case, async: true
  doctest ElasticPriceEngine.ViewCountStrategy

  alias ElasticPriceEngine.Reducer
  alias ElasticPriceEngine.ViewCountStrategy, as: Schema

  setup_all do
    {:ok, opts} = Schema.validate(id: "foo", decrement: 100, increment: 100, step: 3)
    [state: struct(Schema, opts)]
  end

  describe "increment" do
    test "count", %{state: state} do
      state
      |> Reducer.increment()
      |> Reducer.count()
      |> (& assert &1 == 1).()

      %{state | views: 87}
      |> Reducer.increment()
      |> Reducer.count()
      |> (& assert &1 == 88).()
    end

    test "amount", %{state: state} do
      %{state | views: 0}
      |> Reducer.increment()
      |> Reducer.amount()
      |> (& assert &1 == usd(0)).()

      %{state | views: 8, price: 8600}
      |> Reducer.increment()
      |> Reducer.amount()
      |> (& assert &1 == usd(87)).()
    end

    test "ceiling", %{state: state} do
      state =
        Enum.reduce(1..3, %{state | views: 165, price: 5400, ceiling: 5500}, fn _, st ->
          Reducer.increment(st)
        end)

      assert Reducer.count(state) == 168
      assert Reducer.amount(state) == usd(55)
    end
  end

  describe "decrement" do
    test "count", %{state: state} do
      %{state | views: 1}
      |> Reducer.decrement()
      |> Reducer.count()
      |> (& assert &1 == 0).()

      %{state | views: 88}
      |> Reducer.decrement()
      |> Reducer.count()
      |> (& assert &1 == 87).()

      %{state | views: 0}
      |> Reducer.decrement()
      |> Reducer.count()
      |> (& assert &1 == 0).()
    end

    test "amount", %{state: state} do
      %{state | views: 7, price: 200}
      |> Reducer.decrement()
      |> Reducer.amount()
      |> (& assert &1 == usd(1)).()

      %{state | views: 5, price: 200}
      |> Reducer.decrement()
      |> Reducer.amount()
      |> (& assert &1 == usd(2)).()

      %{state | views: 0, price: 0}
      |> Reducer.decrement()
      |> Reducer.amount()
      |> (& assert &1 == usd(0)).()
    end

    test "floor", %{state: state} do
      state =
        Enum.reduce(1..4, %{state | floor: 100, views: 4, price: 200}, fn _, st ->
          Reducer.decrement(st)
        end)

      assert Reducer.count(state) == 0
      assert Reducer.amount(state) == usd(1)
    end
  end

  defp usd(amt), do: Money.parse!(amt, :USD)
end
