defmodule ElasticPriceEngine do
  @moduledoc """
  an elastic price engine server is started with:
  1. an increment strategy - that defines when the price should go up and when it should go down
  2. an decrement strategy - that defines when the price should go down and when it should go down

  - strategies define increment, decrements, as well as thresholds like a floor and ceiling
  """

  use GenServer

  defstruct count: 0, price: 0

  def start_link(key, state \\ %__MODULE__{}) when is_binary(key) do
    GenServer.start_link(__MODULE__, state, name: registry_name(key))
  end

  def inc(key) do
    GenServer.cast(registry_name(key), :inc)
  end

  def price(key) do
    GenServer.call(registry_name(key), :price)
  end

  defp registry_name(key) do
    {:via, Registry, {EPE.Registry, key}}
  end

  # server (callbacks)

  @impl true
  def init(engine), do: {:ok, engine}

  @impl true
  def handle_cast(:inc, counter = %{count: curr_cnt, price: curr_price}) do
    state = %{counter | count: curr_cnt + 1, price: update_price(curr_price, curr_cnt)}
    {:noreply, state}
  end

  @impl true
  def handle_call(:price, _from, counter = %{price: price}) do
    {:reply, price, counter}
  end

  defp update_price(price, count) do
    # as demand goes up, so does the price, as demand goes down, so does the price
    if rem(count, 3) == 0, do: price + 1, else: price
  end
end
