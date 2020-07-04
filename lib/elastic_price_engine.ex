defmodule ElasticPriceEngine do
  @moduledoc """
  An engine is just a stateful genserver performing the duties of a pricing
  strategy for one identifier
  """

  use GenServer

  alias __MODULE__.Reducer

  require Logger

  # client

  @registry __MODULE__.EngineReg

  def child_spec(opts) do
    id = Keyword.get(opts, :id, __MODULE__)

    %{
      id: "#{__MODULE__}_#{id}",
      start: {__MODULE__, :start_link, [opts[:state], [id: id]]},
      restart: :transient
    }
  end

  def start_link(state, opts \\ []) do
    case GenServer.start_link(__MODULE__, state, name: via_tuple(opts[:id])) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        Logger.info("already started at #{inspect(pid)}, returning :ignore")
        :ignore
    end
  end

  def increment(id) when is_pid(id), do: GenServer.cast(id, :increment)
  def increment(id), do: GenServer.cast(via_tuple(id), :increment)

  def decrement(id) when is_pid(id), do: GenServer.cast(id, :decrement)
  def decrement(id), do: GenServer.cast(via_tuple(id), :decrement)

  def amount(id) when is_pid(id), do: GenServer.call(id, :amount)
  def amount(id), do: GenServer.call(via_tuple(id), :amount)

  def count(id) when is_pid(id), do: GenServer.call(id, :count)
  def count(id), do: GenServer.call(via_tuple(id), :count)

  def stop(id) when is_pid(id), do: GenServer.stop(id, :normal)
  def stop(id), do: GenServer.stop(via_tuple(id), :normal)

  defp via_tuple(id), do: {:via, Registry, {@registry, id}}

  # server (callbacks)

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_cast(action, state) do
    {:noreply, apply(Reducer, action, [state])}
  end

  @impl true
  def handle_call(:amount, _from, state) do
    {:reply, Reducer.amount(state), state}
  end

  @impl true
  def handle_call(:count, _from, state) do
    {:reply, Reducer.count(state), state}
  end

  @impl true
  def terminate(reason, _), do: reason
end
