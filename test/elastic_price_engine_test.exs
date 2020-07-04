defmodule ElasticPriceEngineTest do
  use ExUnit.Case, async: true
  doctest ElasticPriceEngine

  alias ElasticPriceEngine, as: Engine
  alias ElasticPriceEngine.ViewCountStrategy, as: Strategy

  setup do
    {:ok, strategy_opts} = Strategy.validate(increment: 100, decrement: 100, step: 3)
    state = struct(Strategy, strategy_opts)
    {:ok, pid} = ElasticPriceEngine.start_link(state)
    %{pid: pid}
  end

  describe "ElasticPriceEngine.increment/0" do
    test "increment", %{pid: pid} do
      for _ <- 1..5, do: Engine.increment(pid)
      assert Engine.count(pid) == 5
    end
  end

  describe "ElasticPriceEngine.decrement/1" do
    test "decrement", %{pid: pid} do
      for _ <- 1..3, do: Engine.increment(pid)
      assert Engine.count(pid) == 3
      Engine.decrement(pid)
      assert Engine.count(pid) == 2
    end
  end

  describe "ElasticPriceEngine.amount/1" do
    test "increases after count goes up", %{pid: pid} do
      assert Engine.amount(pid) == usd(0)
      for _ <- 1..3, do: Engine.increment(pid)
      assert Engine.amount(pid) == usd(1)
    end
  end

  describe "ElasticPriceEngine.count/1" do
    test "initial count is zero", %{pid: pid} do
      assert Engine.count(pid) == 0
    end
  end

  describe "ElasticPriceEngine.stop/1" do
    test "engine is no longer active", %{pid: pid} do
      Engine.stop(pid)
      assert Process.alive?(pid) == false
    end
  end

  describe "increment" do
    setup do
      start_engine = fn ->
        {:ok, valid_opts} = Strategy.validate(increment: 100, decrement: 100, step: 3)
        state = struct(Strategy, valid_opts)

        DynamicSupervisor.start_child(
          Engine.EngineSup,
          ElasticPriceEngine.child_spec(id: 0, state: state)
        )
      end

      {:ok, pid} =
        with {:ok, _} <- start_supervised({Registry, keys: :unique, name: Engine.EngineReg}),
             {:ok, _} <- start_supervised({DynamicSupervisor, name: Engine.EngineSup}) do
          start_engine.()
        else
          {:error, {{:already_started, _}, _}} -> start_engine.()
        end

      %{id: pid}
    end

    test "with registry", %{id: id} do
      for _ <- 1..5, do: Engine.increment(id)
      assert Engine.count(id) == 5
    end
  end

  defp usd(amt), do: Money.parse!(amt, :USD)
end
