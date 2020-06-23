defmodule ElasticPriceEngine.Supervisor do
  use Supervisor

  @app_supervisor __MODULE__
  @dynamic_supervisor ElasticPriceEngine.EngineSupervisor
  @engine_registry ElasticPriceEngine.EngineRegistry

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {Registry, keys: :unique, name: @engine_registry},
      {DynamicSupervisor, strategy: :one_for_one, name: @dynamic_supervisor}
    ]

    options = [strategy: :one_for_one, name: @app_supervisor]
    Supervisor.init(children, options)
  end
end
