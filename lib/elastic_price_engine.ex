defmodule ElasticPriceEngine do
  @moduledoc """
  an elastic amount engine server is started with:
  1. an increment strategy - that defines when the amount should go up and when it should go down
  2. an decrement strategy - that defines when the amount should go down and when it should go down

  - strategies define increment, decrements, as well as thresholds like a floor and ceiling
  """

  use GenServer

  alias __MODULE__.Reducer

  # client

  def start(id, strategy, opts \\ []) do
    case NimbleOptions.validate(opts, strategy.options_schema()) do
      {:ok, opts} ->
        state = struct(strategy, opts)
        reg_key = registry_key(id)
        GenServer.start_link(__MODULE__, state, name: reg_key)

      {:error, %NimbleOptions.ValidationError{} = err} ->
        {:error, Exception.message(err)}
    end
  end

  def increment(id), do: GenServer.cast(registry_key(id), :increment)

  def decrement(id), do: GenServer.cast(registry_key(id), :decrement)

  def amount(id), do: GenServer.call(registry_key(id), :amount)

  def stop(id), do: GenServer.stop(registry_key(id), :normal)

  defp registry_key(id), do: {:via, Registry, {EPE.Registry, id}}

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
  def terminate(reason, _), do: reason
end
