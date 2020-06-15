defmodule ElasticPriceEngine do
  @moduledoc """
  an elastic amount engine server is started with:
  1. an increment strategy - that defines when the amount should go up and when it should go down
  2. an decrement strategy - that defines when the amount should go down and when it should go down

  - strategies define increment, decrements, as well as thresholds like a floor and ceiling
  """

  use GenServer

  # client

  def start_link(key, strategy) do
    GenServer.start_link(__MODULE__, struct(strategy), name: registry_name(key))
  end

  def increment(key) do
    GenServer.cast(registry_name(key), :increment)
  end

  def decrement(key) do
    GenServer.cast(registry_name(key), :decrement)
  end

  def amount(key) do
    GenServer.call(registry_name(key), :amount)
  end

  defp registry_name(key) do
    {:via, Registry, {EPE.Registry, key}}
  end

  # server (callbacks)

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_cast(action, state) do
    strategy = state.__struct__
    new_state = apply(strategy, action, [state])
    {:noreply, new_state}
  end

  @impl true
  def handle_call(:amount, _from, state = %{amount: amount}) do
    {:reply, amount, state}
  end
end
