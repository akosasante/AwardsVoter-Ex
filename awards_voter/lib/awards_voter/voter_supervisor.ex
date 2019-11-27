defmodule AwardsVoter.VoterSupervisor do
  use DynamicSupervisor
  
  alias AwardsVoter.Voter
  
  # Public Module API
  def start_link(_init_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end
  
  def add_new_voter(name, show) do
    case DynamicSupervisor.start_child(__MODULE__, {Voter, [name, show]}) do
      {:ok, game} -> {:ok, game}
      {:error, {:already_started, game}} -> {:already_started, game}
      e -> 
        IO.puts("Unexpected error when adding new voter: #{inspect e}")
        raise e  
    end
  end
  
  def shutdown_voter(name) do
    DynamicSupervisor.terminate_child(__MODULE__, pid_from_name(name))
  end
  
  # Server Callbacks
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
  
  defp pid_from_name(name) do
    name
    |> Voter.via_tuple()
    |> GenServer.whereis()
  end

end
