defmodule AwardsVoter.Context.Voting.Votes.Voter do
  use GenServer, restart: :transient # Only restart if it terminates abnormally. we may want to remove this and keep the default of always restarting :permanent

  alias AwardsVoter.Context.Voting.Ballots.BallotState
  alias AwardsVoter.Context.Voting.Ballots.Ballot
  alias AwardsVoter.Context.Admin.Shows.Show

  require Logger

  # kill process after 1 day of inactivity
  @timeout 24 * 60 * 60 * 1000
  @voter_ballot_table Application.get_env(:awards_voter, :voter_ballots_table)

  defmodule VoterState do
    defstruct [:ballot_state, :show, :ballot, :score]
  end
  # TODO: Maybe have spec on at least the client API?
#  def via_tuple(name), do: {:via, Registry, {Registry.Voter, name}}

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
  
  ###############################################

  @spec reset_show(GenServer.server(), Show.t()) :: :ok
  def reset_show(voter, %Show{} = show) do
    GenServer.call(voter, {:reset_show, show})
  end

  @spec reset_ballot(GenServer.server(), String.t()) :: :ok
  def reset_ballot(voter, voter_name) do
    GenServer.call(voter, {:reset_ballot, voter_name})
  end

  @spec vote(GenServer.server(), String.t(), String.t()) :: :ok
  def vote(voter, category, contestant) do
    GenServer.call(voter, {:vote, category, contestant})
  end

  @spec submit_ballot(GenServer.server()) :: :ok
  def submit_ballot(voter) do
    GenServer.call(voter, {:submit_ballot})
  end

  @spec end_show(GenServer.server()) :: :ok
  def end_show(voter) do
    GenServer.call(voter, {:end_show})
  end

  @spec tally_ballot(GenServer.server()) :: :ok
  def tally_ballot(voter) do
    GenServer.call(voter, {:tally})
  end

  # Server Callbacks
  def init(_args) do
    # Set up an DETS table to store voter ballots
#    {:ok, _name} = :dets.open_file(@voter_ballot_table, [])
#    send(self(), {:set_state, voter_name, show})
#
#    return_value = case fresh_state(voter_name, show) do
#      {:error, reason} ->
#        Logger.error("Encountered an error setting initial state: #{inspect reason}")
#        {:stop, reason}
#
#
#      valid_state ->
#        {:ok, valid_state}
#    end
#
#    if close_dets_after do
#      :dets.close(@voter_ballot_table)
#    end

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

  ###########################
  def handle_call({:reset_show, show}, _from, state) do
    with {:ok, ballot_state} <- BallotState.check(state.ballot_state, :set_show) do
      state
      |> update_ballot_state(ballot_state)
      |> update_voter_show(show)
      |> reply_success
    else
      :error -> reply_error(state, :state_error)
    end
  end

  def handle_call({:reset_ballot, voter_name}, _from, state) do
    with {:ok, ballot_state} <- BallotState.check(state.ballot_state, :set_ballot),
         {:ok, ballot} <- Ballot.new(voter_name, state.show) do
      state
      |> update_ballot_state(ballot_state)
      |> update_voter_ballot(ballot)
      |> reply_success
    else
      :error -> reply_error(state, :state_error)
      {:error, reason} -> reply_error(state, reason)
    end
  end

  def handle_call({:vote, category_name, contestant_name}, _from, state) do
    with {:ok, ballot_state} <- BallotState.check(state.ballot_state, :vote),
         {:ok, ballot} <- Ballot.vote(state.ballot, category_name, contestant_name) do
      state
      |> update_ballot_state(ballot_state)
      |> update_voter_ballot(ballot)
      |> reply_success
    else
      :error -> reply_error(state, :state_error)
      {:invalid_vote, _} -> reply_error(state, :invalid_vote)
    end
  end

  def handle_call({:submit_ballot}, _from, state) do
    with {:ok, ballot_state} <- BallotState.check(state.ballot_state, :submit) do
      state
      |> update_ballot_state(ballot_state)
      |> reply_success
    else
      :error -> reply_error(state, :state_error)
    end
  end

  def handle_call({:end_show}, _from, state) do
    with {:ok, ballot_state} <- BallotState.check(state.ballot_state, :end_show) do
      state
      |> update_ballot_state(ballot_state)
      |> reply_success
    else
      :error -> reply_error(state, :state_error)
    end
  end

  def handle_call({:tally}, _from, state) do
    with {:ok, ballot_state} <- BallotState.check(state.ballot_state, :get_score),
         {:ok, score} <- Ballot.score(state.ballot) do
      state
      |> update_ballot_state(ballot_state)
      |> update_ballot_score(score)
      |> reply_success
    else
      :error -> reply_error(state, :state_error)
    end
  end

  def handle_info({:set_state, voter_name, show}, _state) do
    voter_state =
      case :dets.lookup(@voter_ballot_table, voter_name) do
        [] -> fresh_state(voter_name, show)
        [{_key, state}] -> state
      end

    case voter_state do
      :state_error ->
        Logger.info("Encountered an invalid state change when setting initial state")
        {:stop, :state_error, %VoterState{}}

      valid_state ->
        :dets.insert(@voter_ballot_table, {voter_name, valid_state})
        {:noreply, valid_state, @timeout}
    end
  end

  def handle_info(:timeout, state) do
    {:stop, {:shutdown, :timeout}, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  def terminate(reason, _state) do
    Logger.info("Terminating Voter GenServer due to: #{inspect reason}")
    :dets.close(@voter_ballot_table)
  end

  # Private Methods

  defp update_ballot_state(voter_state, %BallotState{} = ballot_state),
       do: %{voter_state | ballot_state: ballot_state}

  defp update_voter_show(voter_state, %Show{} = show), do: %{voter_state | show: show}

  defp update_voter_ballot(voter_state, %Ballot{} = ballot), do: %{voter_state | ballot: ballot}

  defp update_ballot_score(voter_state, score), do: %{voter_state | score: score}

  defp reply_error(voter_state, reply_atom), do: {:reply, reply_atom, voter_state, @timeout}

  defp reply_success(voter_state, reply_atom \\ :ok) do
    :dets.insert(@voter_ballot_table, {voter_state.ballot.voter, voter_state})
    {:reply, reply_atom, voter_state, @timeout}
  end


  defp   fresh_state(voter_name, show) do
    Logger.info("Getting fresh state")
    with {:ok, ballot_state} <- BallotState.new(),
         {:ok, ballot_state} <- BallotState.check(ballot_state, :set_show),
         {:ok, ballot_state} <- BallotState.check(ballot_state, :set_ballot),
         {:ok, ballot} <- Ballot.new(voter_name, show) do
      %VoterState{}
      |> update_ballot_state(ballot_state)
      |> update_voter_show(show)
      |> update_voter_ballot(ballot)
    else
      :error -> {:error, :state_error}
      other_error -> {:error, other_error}
    end
  end
  
  defp open_table(close_dets_after \\ Mix.env() == :test) do
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