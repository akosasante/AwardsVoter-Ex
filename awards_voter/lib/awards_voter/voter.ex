defmodule AwardsVoter.Voter do
  use GenServer, restart: :transient

  alias AwardsVoter.{BallotState, Show, Ballot}
  
  @timeout 24 * 60 * 60 * 1000 # kill process after 1 day of inactivity

  defmodule VoterState do
    defstruct [:ballot_state, :show, :ballot, :score]
  end
  
  def via_tuple(name), do: {:via, Registry, {Registry.Voter, name}}

  # Client API
  def start_link([voter_name, show]) do
    GenServer.start_link(__MODULE__, {voter_name, show}, name: via_tuple(voter_name))
  end

  def reset_voter(voter) do
    GenServer.call(voter, {:reset_voter})
  end

  def reset_show(voter, %Show{} = show) do
    GenServer.call(voter, {:reset_show, show})
  end

  def reset_ballot(voter, voter_name) do
    GenServer.call(voter, {:reset_ballot, voter_name})
  end

  def vote(voter, category, contestant) do
    GenServer.call(voter, {:vote, category, contestant})
  end

  def submit_ballot(voter) do
    GenServer.call(voter, {:submit_ballot})
  end

  def end_show(voter) do
    GenServer.call(voter, {:end_show})
  end

  def tally_ballot(voter) do
    GenServer.call(voter, {:tally})
  end

  # Server Callbacks
  def init({voter_name, show}) do
    send(self(), {:set_state, voter_name, show})
    case fresh_state(voter_name, show) do
      :state_error ->
        IO.puts "Encountered an invalid state change when setting initial state"
        {:stop, :state_error}
      valid_state -> {:ok, valid_state}
    end
  end

  def handle_call({:reset_voter}, _from, state) do
    with {:ok, ballot_state} <- BallotState.check(state.ballot_state, :reset_state) do
      state
      |> update_ballot_state(ballot_state)
      |> reply_success(:ok)
    else
      :error -> reply_error(state, :state_error)
    end
  end

  def handle_call({:reset_show, show}, _from, state) do
    with {:ok, ballot_state} <- BallotState.check(state.ballot_state, :set_show) do
      state
      |> update_ballot_state(ballot_state)
      |> update_voter_show(show)
      |> reply_success(:ok)
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
      |> reply_success(:ok)
    else
      :error -> reply_error(state, :state_error)
    end
  end

  def handle_call({:vote, category_name, contestant_name}, _from, state) do
    with {:ok, ballot_state} <- BallotState.check(state.ballot_state, :vote),
         {:ok, ballot} <- Ballot.vote(state.ballot, category_name, contestant_name) do
      state
      |> update_ballot_state(ballot_state)
      |> update_voter_ballot(ballot)
      |> reply_success(:ok)
    else
      :error -> reply_error(state, :state_error)
      {:invalid_vote, _} -> reply_error(state, :invalid_vote)
    end
  end

  def handle_call({:submit_ballot}, _from, state) do
    with {:ok, ballot_state} <- BallotState.check(state.ballot_state, :submit) do
      state
      |> update_ballot_state(ballot_state)
      |> reply_success(:ok)
    else
      :error -> reply_error(state, :state_error)
    end
  end

  def handle_call({:end_show}, _from, state) do
    with {:ok, ballot_state} <- BallotState.check(state.ballot_state, :end_show) do
      state
      |> update_ballot_state(ballot_state)
      |> reply_success(:ok)
    end
  end

  def handle_call({:tally}, _from, state) do
    with {:ok, ballot_state} <- BallotState.check(state.ballot_state, :get_score),
         {:ok, score} <- Ballot.score(state.ballot) do
      state
      |> update_ballot_state(ballot_state)
      |> update_ballot_score(score)
      |> reply_success(:ok)
    else
      :error -> reply_error(state, :state_error)
    end
  end
  
  def handle_info({:set_state, voter_name, show}, state) do
    voter_state = case :ets.lookup(:voter_ballots, voter_name) do
      [] -> fresh_state(voter_name, show)
      [{_key, state}] -> state
    end
    case voter_state do
      :state_error -> 
        IO.puts "Encountered an invalid state change when setting initial state"
        {:stop, :state_error, %VoterState{}}
      valid_state ->
        :ets.insert(:voter_ballots, {voter_name, valid_state})
        {:noreply, valid_state, @timeout}
    end
  end
  
  def handle_info(:timeout, state) do
    {:stop, {:shutdown, :timeout}, state}
  end
  
  def terminate({:shutdown, :timeout}, state) do
    :ets.delete(:voter_ballots, state.ballot.voter)
    :ok
  end
  def terminate(_reason, _state), do: :ok

  # Private Methods

  defp update_ballot_state(voter_state, %BallotState{} = ballot_state),
    do: %{voter_state | ballot_state: ballot_state}

  defp update_voter_show(voter_state, %Show{} = show), do: %{voter_state | show: show}

  defp update_voter_ballot(voter_state, %Ballot{} = ballot), do: %{voter_state | ballot: ballot}

  defp update_ballot_score(voter_state, score), do: %{voter_state | score: score}

  defp reply_error(voter_state, reply_atom), do: {:reply, reply_atom, voter_state, @timeout}
  defp reply_success(voter_state, reply_atom) do
    :ets.insert(:voter_ballots, {voter_state.ballot.voter, voter_state})
    {:reply, reply_atom, voter_state, @timeout}
  end
  
  defp fresh_state(voter_name, show) do
    with {:ok, ballot_state} <- BallotState.new(),
         {:ok, ballot_state} <- BallotState.check(ballot_state, :set_show),
         {:ok, ballot_state} <- BallotState.check(ballot_state, :set_ballot),
         {:ok, ballot} <- Ballot.new(voter_name, show) do
      %VoterState{}
      |> update_ballot_state(ballot_state)
      |> update_voter_show(show)
      |> update_voter_ballot(ballot)
    else
      :error -> :state_error
    end
  end
end
