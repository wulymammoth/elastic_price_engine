defmodule ElasticPriceEngine.Supervisor do
  use Supervisor

  @registry_name EPE.Registry
  @supervisor_name EPE.EngineSupervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {Registry, keys: :unique, name: @registry_name},
      {DynamicSupervisor, strategy: :one_for_one, name: @supervisor_name}
    ]

    options = [strategy: :one_for_one, name: @supervisor_name]
    Supervisor.init(children, options)
  end
end
