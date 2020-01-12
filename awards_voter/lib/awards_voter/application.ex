defmodule AwardsVoter.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  
  require Logger

  def start(_type, _args) do
    
    children = [
      {Registry, keys: :unique, name: Registry.Voter},
      AwardsVoter.VoterSupervisor,
      AwardsVoter.ShowManager
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AwardsVoter.Supervisor]
    Logger.info("Starting awards_voter application with children: #{inspect children}")
    Supervisor.start_link(children, opts)
  end
  
  def stop(state) do
    Logger.info("Application shutting down: #{inspect state}")
    :ok
  end
end
