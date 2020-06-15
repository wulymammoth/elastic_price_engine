defmodule ElasticPriceEngineTest do
  use ExUnit.Case
  doctest ElasticPriceEngine

  alias ElasticPriceEngine, as: Engine

  @key 123

  setup_all do
    {:ok, _} = Registry.start_link(keys: :unique, name: EPE.Registry)
    :ok
  end

  setup do
    {:ok, _} = Engine.start_link(@key, ElasticPriceEngine.CounterStrategy)
    :ok
  end

  test "amount increases after count goes up" do
    assert Engine.amount(@key) == usd(0)
    for _ <- 1..3, do: Engine.increment(@key)
    assert Engine.amount(@key) == usd(1)
  end

  test "amount decreases after count goes down" do
    for _ <- 1..6, do: Engine.increment(@key)
    assert Engine.amount(@key) == usd(2)
    for _ <- 1..3, do: Engine.decrement(@key)
    assert Engine.amount(@key) == usd(1)
  end

  test "get" do
  end

  test "perform" do
  end

  def usd(amt), do: Money.parse!(amt, :USD)
end
