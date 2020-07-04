defmodule ElasticPriceEngine.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: ElasticPriceEngine.Worker.start_link(arg)
      # {ElasticPriceEngine.Worker, arg}
      {Registry, name: ElasticPriceEngine.EngineReg, keys: :unique},
      {DynamicSupervisor, name: ElasticPriceEngine.EngineSup, strategy: :one_for_one}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    Supervisor.start_link(children, name: ElasticPriceEngine.Supervisor, strategy: :one_for_one)
  end
end
