defmodule AwardsVoter.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Registry.Voter},
      AwardsVoter.VoterSupervisor
    ]

    # Set up an ETS table to 
    :ets.new(:voter_ballots, [:public, :named_table])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AwardsVoter.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
