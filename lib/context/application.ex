defmodule AwardsVoter.Context.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  def start(_type, _args) do
    web_children = [
      # Start the Ecto repository
      #      AwardsVoter.Repo,
      # Start the Telemetry supervisor
      AwardsVoter.Web.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: AwardsVoter.PubSub},
      # Start the Endpoint (http/https)
      AwardsVoter.Web.Endpoint,
      # Start a worker by calling: AwardsVoter.Worker.start_link(arg)
      # {AwardsVoter.Worker, arg}
    ]

    dets_children = [
      {AwardsVoter.Context.Tables.ShowTable, []},
      {AwardsVoter.Context.Tables.BallotTable, []}
    ]

    dets_children = if Application.get_env(:awards_voter, :run_backups) do
      dets_children ++ [{AwardsVoter.Context.Tables.BackupServer, [tables: [AwardsVoter.Context.Tables.ShowTable, AwardsVoter.Context.Tables.BallotTable]]}]
    else
      Logger.info("Will not backup DETS tables to S3")
      dets_children
    end

    children = dets_children ++ web_children

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AwardsVoter.Context.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AwardsVoter.Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
