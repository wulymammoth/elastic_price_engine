defmodule ElasticPriceEngine do
  @moduledoc """
  an elastic price engine server is started with:
  1. an increment strategy - that defines when the price should go up and when it should go down
  2. an decrement strategy - that defines when the price should go down and when it should go down

  - strategies define increment, decrements, as well as thresholds like a floor and ceiling
  """

  use GenServer

  defstruct count: 0, price: 0

  def start_link(key, state \\ %__MODULE__{}) do
    GenServer.start_link(__MODULE__, state, name: registry_name(key))
  end

  def increment(key) do
    GenServer.cast(registry_name(key), :increment)
  end

  def decrement(key) do
    GenServer.cast(registry_name(key), :decrement)
  end

  def count(key) do
    GenServer.call(registry_name(key), :count)
  end

  def price(key) do
    GenServer.call(registry_name(key), :price)
  end

  defp registry_name(key) do
    {:via, Registry, {EPE.Registry, key}}
  end

  # server (callbacks)

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_cast(:increment, state = %{count: count, price: price}) do
    new_count = count + 1
    new_price = if rem(count, 3) == 0, do: price + 1, else: price
    {:noreply, %{state | count: new_count, price: new_price}}
  end

  @impl true
  def handle_cast(:decrement, state = %{count: count, price: price}) do
    new_count = count - 1
    new_price = if rem(count, 3) == 0, do: price - 1, else: price
    {:noreply, %{state | count: new_count, price: new_price}}
  end

  @impl true
  def handle_call(:count, _from, state = %{count: count}) do
    {:reply, count, state}
  end

  @impl true
  def handle_call(:price, _from, state = %{price: price}) do
    {:reply, price, state}
  end
end
