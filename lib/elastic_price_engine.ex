defmodule ElasticPriceEngine do
  @moduledoc """
  An engine is just a stateful genserver performing the duties of a pricing
  strategy for one identifier
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

  def count(id), do: GenServer.call(registry_key(id), :count)

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
  def handle_call(:count, _from, state) do
    {:reply, Reducer.count(state), state}
  end

  @impl true
  def terminate(reason, _), do: reason
end
