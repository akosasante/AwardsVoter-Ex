defmodule AwardsVoter.Context.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    show_table_name = Application.get_env(:awards_voter, :show_table_name)
    ballot_table_name = Application.get_env(:awards_voter, :ballot_table_name)
    {:ok, _} = :dets.open_file(show_table_name, file: './#{show_table_name}.dets')
    {:ok, _} = :dets.open_file(ballot_table_name, file: './#{ballot_table_name}.dets')

    children = [
      # Start the Ecto repository
      #      AwardsVoter.Repo,
      # Start the Telemetry supervisor
      AwardsVoter.Web.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: AwardsVoter.PubSub},
      # Start the Endpoint (http/https)
      AwardsVoter.Web.Endpoint,
      {AwardsVoter.Context.Tables.ShowTable, [table_name: show_table_name]},
      {AwardsVoter.Context.Tables.BallotTable, [table_name: ballot_table_name]},
      {AwardsVoter.Context.Tables.BackupServer, [tables: [show_table_name, ballot_table_name]]}
      # Start a worker by calling: AwardsVoter.Worker.start_link(arg)
      # {AwardsVoter.Worker, arg}
    ]

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
