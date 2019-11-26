defmodule AwardsVoter.Voter do
  use GenServer
  
  alias AwardsVoter.{BallotState, Show, Ballot}
  
  defmodule VoterState do
    defstruct [:ballot_state, :show, :ballot, :score]
  end
  
  # Client API
  def start_new_voter(voter_name, show) do
    GenServer.start_link(__MODULE__, {voter_name, show}, [])
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
    with {:ok, ballot_state} <- BallotState.new(),
      {:ok, ballot_state} <- BallotState.check(ballot_state, :set_show),
      {:ok, ballot_state} <- BallotState.check(ballot_state, :set_ballot),
      {:ok, ballot} <- Ballot.new(voter_name, show)
    do
      voter_state = %VoterState{}
      |> update_ballot_state(ballot_state)
      |> update_voter_show(show)
      |> update_voter_ballot(ballot)
      {:ok, voter_state}
    else
      :error -> reply_with_atom(%VoterState{}, :state_error)
    end
  end

  def handle_call({:reset_voter}, _from, state) do
    with {:ok, ballot_state} <- BallotState.check(state.ballot_state, :reset_state)
      do
      state
      |> update_ballot_state(ballot_state)
      |> reply_with_atom(:ok)
    else
      :error -> reply_with_atom(state, :state_error)
    end
  end
  
  def handle_call({:reset_show, show}, _from, state) do
    with {:ok, ballot_state} <- BallotState.check(state.ballot_state, :set_show)
      do
        state
        |> update_ballot_state(ballot_state)
        |> update_voter_show(show)
        |> reply_with_atom(:ok)
    else
      :error -> reply_with_atom(state, :state_error)
    end
  end
  
  def handle_call({:reset_ballot, voter_name}, _from, state) do
    with {:ok, ballot_state} <- BallotState.check(state.ballot_state, :set_ballot),
         {:ok, ballot} <- Ballot.new(voter_name, state.show)
    do
      state
      |> update_ballot_state(ballot_state)
      |> update_voter_ballot(ballot)
      |> reply_with_atom(:ok)
    else
      :error -> reply_with_atom(state, :state_error)
    end
  end
  
  def handle_call({:vote, category_name, contestant_name}, _from, state) do
    with {:ok, ballot_state} <- BallotState.check(state.ballot_state, :vote),
         {:ok, ballot} <- Ballot.vote(state.ballot, category_name, contestant_name)
      do
        state
        |> update_ballot_state(ballot_state)
        |> update_voter_ballot(ballot)
        |> reply_with_atom(:ok)
    else
      :error -> reply_with_atom(state, :state_error)
    end
  end
  
  def handle_call({:submit_ballot}, _from, state) do
    with {:ok, ballot_state} <- BallotState.check(state.ballot_state, :submit)
      do
        state
        |> update_ballot_state(ballot_state)
        |> reply_with_atom(:ok)
    else
      :error -> reply_with_atom(state, :state_error)
    end
  end
  
  def handle_call({:end_show}, _from, state) do
    with {:ok, ballot_state} <- BallotState.check(state.ballot_state, :end_show)
      do
        state
        |> update_ballot_state(ballot_state)
        |> reply_with_atom(:ok)
    end
  end
  
  def handle_call({:tally}, _from, state) do
    with {:ok, ballot_state} <- BallotState.check(state.ballot_state, :get_score),
         {:ok, score} <- Ballot.score(state.ballot)
      do
        state
        |> update_ballot_state(ballot_state)
        |> update_ballot_score(score)
        |> reply_with_atom(:ok)
    else
      :error -> reply_with_atom(state, :state_error)
    end
  end
  
  # Private Methods
  
  defp update_ballot_state(voter_state, %BallotState{} = ballot_state), do: %{voter_state | ballot_state: ballot_state}
  
  defp update_voter_show(voter_state, %Show{} = show), do: %{voter_state | show: show}
  
  defp update_voter_ballot(voter_state, %Ballot{} = ballot), do: %{voter_state | ballot: ballot}
  
  defp update_ballot_score(voter_state, score), do: %{voter_state | score: score}
  
  defp reply_with_atom(voter_state, reply_atom), do: {:reply, reply_atom, voter_state}
end
