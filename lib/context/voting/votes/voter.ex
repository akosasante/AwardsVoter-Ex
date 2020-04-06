defmodule AwardsVoter.Context.Voting.Votes.Voter do
  use GenServer, restart: :transient # Only restart if it terminates abnormally. we may want to remove this and keep the default of always restarting :permanent

  require Logger

  @voter_ballot_table Application.get_env(:awards_voter, :voter_ballots_table)

  defmodule VoterState do
    defstruct [:ballot_state, :show, :ballot, :score]
  end

  # Client API
  def start_link(_args) do
    open_table()
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end
  
  def save_ballot(ballot, show_name) do
    GenServer.call(__MODULE__, {:upsert_ballot, ballot, show_name})
  end

  def get_ballot_by_voter_and_show(voter, show) do
    GenServer.call(__MODULE__, {:get_ballot, voter, show})
  end
  
  def list_ballots_for_voter(voter) do
    GenServer.call(__MODULE__, {:list_voter_ballots, voter})
  end
  
  def list_ballots_for_show(show) do
    GenServer.call(__MODULE__, {:list_show_ballots, show})
  end

  # Server Callbacks
  def init(_args) do
    Logger.info("Starting Voter Server")
    {:ok, @voter_ballot_table}
  end
  
  def handle_call({:upsert_ballot, ballot, show_name}, _from, state) do
    Logger.debug "Handling :upsert_ballot {#{show_name}_#{ballot.voter}} call"
    res = :dets.insert(@voter_ballot_table, {{show_name, ballot.voter}, ballot})
    {:reply, res, state}
  end

  def handle_call({:get_ballot, voter, show}, _from, state) do
    Logger.debug "Handling :get_ballot #{inspect voter}/#{inspect show} call"
    ballot = case :dets.lookup(@voter_ballot_table, {show, voter}) do
      [] -> :not_found
      [{_key, saved_ballot}] -> saved_ballot
    end
    {:reply, ballot, state}
  end
  
  def handle_call({:list_voter_ballots, voter}, _from, state) do
    Logger.debug "Handling :list_voter_ballots for #{inspect voter} call"
    res = :dets.match_object(@voter_ballot_table, {{:_, voter}, :_})
    matching_ballots = Enum.map(res, fn {{_show, _voter}, ballot} -> ballot end)
    {:reply, matching_ballots, state}
  end
  
  def handle_call({:list_show_ballots, show}, _from, state) do
    Logger.debug "Handling :list_show_ballots for #{inspect show} call"
    res = :dets.match_object(@voter_ballot_table, {{show, :_}, :_})
    matching_ballots = Enum.map(res, fn {{_show, _voter}, ballot} -> ballot end)
    {:reply, matching_ballots, state}
  end
  
  def terminate(reason, _state) do
    Logger.info("Terminating Voter GenServer due to: #{inspect reason}")
    :dets.close(@voter_ballot_table)
  end

  # Private Methods
  defp open_table(close_dets_after \\ Application.get_env(:awards_voter, :environment) == :test) do
    filepath = Path.absname("./ballots", File.cwd!())
               |> Path.expand()
               |> String.to_charlist()
    {:ok, _name} = :dets.open_file(@voter_ballot_table, [file: filepath])
    Logger.info("Opened DETS table at #{@voter_ballot_table}")
    if close_dets_after do
      :dets.close(@voter_ballot_table)
    end
  end
end