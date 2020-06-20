defmodule ElasticPriceEngineTest do
  use ExUnit.Case
  doctest ElasticPriceEngine

  alias ElasticPriceEngine, as: Engine
  alias ElasticPriceEngine.ViewCountStrategy

  @id 123

  setup_all do
    {:ok, registry} = Registry.start_link(keys: :unique, name: EPE.Registry)
    on_exit(make_ref(), fn -> Process.exit(registry, :kill) end)
    :ok
  end

  setup do
    opts = [increment: 100, decrement: 100, step: 3]
    {:ok, engine} = Engine.start(@id, ViewCountStrategy, opts)
    on_exit(make_ref(), fn -> Process.exit(engine, :kill) end)
    :ok
  end

  test "amount increases after count goes up" do
    assert Engine.amount(@id) == usd(0)
    for _ <- 1..3, do: Engine.increment(@id)
    assert Engine.amount(@id) == usd(1)
  end

  test "amount decreases after count goes down" do
    for _ <- 1..6, do: Engine.increment(@id)
    assert Engine.amount(@id) == usd(2)
    for _ <- 1..3, do: Engine.decrement(@id)
    assert Engine.amount(@id) == usd(1)
  end

  def usd(amt), do: Money.parse!(amt, :USD)
end
