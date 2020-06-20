defmodule ElasticPriceEngine do
  @moduledoc """
  an elastic amount engine server is started with:
  1. an increment strategy - that defines when the amount should go up and when it should go down
  2. an decrement strategy - that defines when the amount should go down and when it should go down

  - strategies define increment, decrements, as well as thresholds like a floor and ceiling
  """

  use GenServer

  alias __MODULE__.PricingStrategy

  import NimbleOptions, only: [validate: 2]

  # client

  def start_link(key, strategy, opts \\ []) do
    case validate(opts, strategy.options_schema()) do
      {:ok, opts} ->
        GenServer.start_link(__MODULE__, struct(strategy, opts), name: registry_name(key))

      {:error, error} ->
        error
    end
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
    {:noreply, apply(PricingStrategy, action, [state])}
  end

  @impl true
  def handle_call(:amount, _from, state) do
    {:reply, PricingStrategy.amount(state), state}
  end
end
