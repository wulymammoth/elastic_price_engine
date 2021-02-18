defmodule ElasticPriceEngineTest do
  use ExUnit.Case, async: true

  doctest ElasticPriceEngine

  alias ElasticPriceEngine, as: Engine
  alias Engine.ViewCountStrategy, as: Strategy

  @default_strategy_opts [increment: 100, decrement: 100, step: 3]

  setup do
    {:ok, pid} = Engine.start_link(state("foo"))
    %{pid: pid}
  end

  test "engine hibernates after being idle" do
    idle_time = 5
    {:ok, pid} = Engine.start_link(state("bar"), hibernate_after: idle_time)
    Process.sleep(idle_time)

    assert :erlang.process_info(pid, :current_function) ==
             {:current_function, {:erlang, :hibernate, 3}}
  end

  describe "ElasticPriceEngine.increment/0" do
    test "increment", %{pid: pid} do
      for _ <- 1..5, do: Engine.increment(pid)
      assert Engine.count(pid) == 6
    end
  end

  describe "ElasticPriceEngine.decrement/1" do
    test "decrement", %{pid: pid} do
      for _ <- 1..3, do: Engine.increment(pid)
      assert Engine.count(pid) == 4
      Engine.decrement(pid)
      assert Engine.count(pid) == 3
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
      assert Engine.count(pid) == 1
    end
  end

  describe "ElasticPriceEngine.stop/1" do
    test "engine is no longer active", %{pid: pid} do
      Engine.stop(pid)
      refute Process.alive?(pid)
    end
  end

  describe "increment" do
    setup do
      id = "baz"

      {:ok, _pid} =
        with {:ok, _} <- start_supervised({Registry, keys: :unique, name: Engine.EngineReg}),
             {:ok, _} <- start_supervised({DynamicSupervisor, name: Engine.EngineSup}) do
          start_engine(id)
        else
          {:error, {{:already_started, _}, _}} -> start_engine(id)
        end

      %{id: id}
    end

    test "with registry", %{id: id} do
      for _ <- 1..5, do: Engine.increment(id)
      assert Engine.count(id) == 6
    end
  end

  defp start_engine(id) do
    DynamicSupervisor.start_child(Engine.EngineSup, Engine.child_spec(state(id)))
  end

  defp state(id) do
    @default_strategy_opts
    |> Keyword.merge(id: id)
    |> Strategy.validate!()
    |> (&struct(Strategy, &1)).()
  end

  defp usd(amt), do: Money.parse!(amt, :USD)
end
