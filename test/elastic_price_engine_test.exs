defmodule ElasticPriceEngineTest do
  use ExUnit.Case
  doctest ElasticPriceEngine

  alias ElasticPriceEngine, as: Server

  @key "foo"

  setup do
    {:ok, _} = Registry.start_link(keys: :unique, name: EPE.Registry)
    {:ok, pid} = Server.start_link(@key)
    :ok
  end

  test "initial state" do
    assert Server.price(@key) == 0
  end

  test "increment" do
    for _ <- 1..3, do: Server.inc(@key)
    assert Server.price(@key) == 1

    for _ <- 1..3, do: Server.inc(@key)
    assert Server.price(@key) == 2
  end
end
