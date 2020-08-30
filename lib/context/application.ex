defmodule AwardsVoter.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
#      AwardsVoter.Repo,
      # Start the endpoint when the application starts
      {Phoenix.PubSub, [name: AwardsVoter.PubSub, adapter: Phoenix.PubSub.PG2]},
      AwardsVoter.Web.Endpoint,
      # Starts a worker by calling: AwardsVoter.Worker.start_link(arg)
      # {AwardsVoter.Worker, arg},
#      {Registry, keys: :unique, name: Registry.Voter},
      AwardsVoter.Context.Voting.Votes.Voter,
      AwardsVoter.Context.Admin.Shows.ShowManager,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AwardsVoter.Supervisor]
    Logger.info("Starting awards_voter application with children: #{inspect children}")
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AwardsVoter.Web.Endpoint.config_change(changed, removed)
    :ok
  end

  def stop(state) do
    Logger.info("Application shutting down: #{inspect state}")
    :ok
  end
end
