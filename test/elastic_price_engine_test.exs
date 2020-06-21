defmodule ElasticPriceEngineTest do
  use ExUnit.Case, async: true
  doctest ElasticPriceEngine

  alias ElasticPriceEngine, as: Engine
  alias ElasticPriceEngine.ViewCountStrategy

  @id 0

  setup_all do
    {:ok, registry} = Registry.start_link(keys: :unique, name: EPE.Registry)
    on_exit(make_ref(), fn -> Process.exit(registry, :kill) end)
    :ok
  end

  setup do
    opts = [increment: 100, decrement: 100, step: 3]
    {:ok, _} = Engine.start(@id, ViewCountStrategy, opts)
    :ok
  end

  test "invalid options" do
    expected_message = "required option :decrement not found, received options: [:currency]"
    opts = []
    assert {:error, expected_message} == Engine.start(@id, ViewCountStrategy, opts)
  end

  test "multiple IDs" do
    opts = [increment: 100, decrement: 100, step: 3]
    ids = 1..2_000
    for id <- ids, do: {:ok, _} = Engine.start(id, ViewCountStrategy, opts)
    for id <- ids, do: for(_ <- 1..150, do: Engine.increment(id))
    for id <- ids, do: assert(Engine.amount(id) == usd(50))
    for id <- ids, do: Engine.stop(id)
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
