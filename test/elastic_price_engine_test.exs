defmodule ElasticPriceEngineTest do
  use ExUnit.Case
  doctest ElasticPriceEngine

  alias ElasticPriceEngine, as: Server

  @key 123

  setup do
    {:ok, _} = Registry.start_link(keys: :unique, name: EPE.Registry)
    {:ok, pid} = Server.start_link(@key)
    :ok
  end

  test "increment" do
    for _ <- 1..3, do: Server.increment(@key)
    assert Server.price(@key) == 1

    for _ <- 1..3, do: Server.increment(@key)
    assert Server.price(@key) == 2
  end

  test "count" do
    assert Server.count(@key) == 0

    for _ <- 1..2, do: Server.increment(@key)
    assert Server.count(@key) == 2
  end

  test "price" do
    assert Server.price(@key) == 0
  end
end
