defmodule ElasticPriceEngine.ViewCountStrategyTest do
  use ExUnit.Case
  doctest ElasticPriceEngine.ViewCountStrategy

  alias ElasticPriceEngine.Strategy
  alias ElasticPriceEngine.ViewCountStrategy, as: Data

  describe "increment" do
    test "count" do
      assert %Data{} |> Strategy.increment() |> Strategy.count() == 1
      assert %Data{views: 87} |> Strategy.increment() |> Strategy.count() == 88
    end

    test "amount" do
      assert %Data{views: 0} |> Strategy.increment() |> Strategy.amount() == usd(0)
      assert %Data{views: 8, price: usd(87)} |> Strategy.increment() |> Strategy.amount() == usd(88)
    end
  end

  describe "decrement" do
    test "count" do
      assert %Data{views: 1} |> Strategy.decrement() |> Strategy.count() == 0
      assert %Data{views: 88} |> Strategy.decrement() |> Strategy.count() == 87
      assert %Data{views: 0} |> Strategy.decrement() |> Strategy.count() == 0
    end

    test "amount" do
      assert %Data{views: 6, price: usd(2)} |> Strategy.decrement() |> Strategy.amount() == usd(1)
      assert %Data{views: 5, price: usd(2)} |> Strategy.decrement() |> Strategy.amount() == usd(2)
      assert %Data{views: 0, price: usd(0)} |> Strategy.decrement() |> Strategy.amount() == usd(0)
    end
  end

  defp usd(amt), do: Money.parse!(amt, :USD)
end
