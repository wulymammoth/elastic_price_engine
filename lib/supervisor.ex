defmodule ElasticPriceEngine.Supervisor do
  use Supervisor

  @dynamic_supervisor ElasticPriceEngine.EngineSupervisor
  @engine_registry ElasticPriceEngine.EngineRegistry

  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok, [])
  end

  @impl true
  def init(:ok) do
    children = [
      {Registry, name: @engine_registry, keys: :unique},
      {DynamicSupervisor, name: @dynamic_supervisor, strategy: :one_for_one}
    ]

    options = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.init(children, options)
  end
end
