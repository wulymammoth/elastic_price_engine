defmodule ElasticPriceEngine do
  @moduledoc """
  An engine is just a stateful genserver performing the duties of a pricing
  strategy for one identifier
  """

  use GenServer

  alias __MODULE__.Reducer

  # client

  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def increment(id), do: GenServer.cast(id, :increment)

  def decrement(id), do: GenServer.cast(id, :decrement)

  def amount(id), do: GenServer.call(id, :amount)

  def count(id), do: GenServer.call(id, :count)

  def stop(id), do: GenServer.stop(id, :normal)

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
