defmodule ElasticPriceEngineTest do
  use ExUnit.Case
  doctest ElasticPriceEngine

  alias ElasticPriceEngine, as: Server

  @key 123
  @registry_name EPE.Registry

  setup do
    {:ok, _} = Registry.start_link(keys: :unique, name: @registry_name)
    {:ok, _} = Server.start_link(@key)
    :ok
  end

  test "increment" do
    for _ <- 1..3, do: assert Server.increment(@key) == :ok
  end

  test "decrement" do
    for _ <- 1..3, do: Server.decrement(@key)
  end

  test "count after incremented" do
    assert Server.count(@key) == 0

    for _ <- 1..2, do: Server.increment(@key)
    assert Server.count(@key) == 2
  end

  test "count after decremented" do
    for _ <- 1..3, do: Server.increment(@key)
    Server.decrement(@key)
    assert Server.count(@key) == 2
  end

  test "price after count goes up" do
    for _ <- 1..3, do: Server.increment(@key)
    assert Server.price(@key) == 1
  end

  test "price after count goes down" do
    for _ <- 1..6, do: Server.increment(@key)
    assert Server.price(@key) == 2
    for _ <- 1..3, do: Server.decrement(@key)
    assert Server.price(@key) == 1
  end
end
