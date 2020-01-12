defmodule AwardsVoter.VoterSupervisor do
  use DynamicSupervisor

  alias AwardsVoter.{Voter, Show, Voter}
  
  require Logger

  # Public Module API
  @spec start_link(term()) :: Supervisor.on_start()
  def start_link(_init_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @spec add_new_voter(String.t(), Show.t()) :: {:ok | :already_started, pid()}
  def add_new_voter(name, show) do
    case DynamicSupervisor.start_child(__MODULE__, {Voter, [name, show]}) do
      {:ok, game} ->
        {:ok, game}

      {:error, {:already_started, game}} ->
        {:already_started, game}

      e ->
        Logger.error("Unexpected error when adding new voter: #{inspect(e)}")
        raise e
    end
  end

  @spec shutdown_voter(String.t()) :: :ok | {:error, :not_found}
  def shutdown_voter(name) do
    :dets.delete(:voter_ballots, name)
    DynamicSupervisor.terminate_child(__MODULE__, pid_from_name(name))
  end

  # Server Callbacks
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec pid_from_name(String.t()) :: pid()
  defp pid_from_name(name) do
    name
    |> Voter.via_tuple()
    |> GenServer.whereis()
  end
end
