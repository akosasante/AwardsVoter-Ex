defmodule AwardsVoter.Context.Voting.Ballots.BallotState do
  alias __MODULE__

  defstruct status: :initialized

  @type t :: %__MODULE__{
               status: :initialized | :show_set | :ballot_set | :voting | :submitted | :show_ended
             }

  @spec new() :: {:ok, BallotState.t()}
  def new(), do: {:ok, %BallotState{}}

  @spec check(BallotState.t(), atom()) :: {:ok, BallotState.t()} | :error
  def check(%BallotState{} = state, :reset_state) do
    case state do
      %BallotState{status: :show_ended} -> :error
      _ -> {:ok, %{state | status: :initialized}}
    end
  end

  def check(%BallotState{status: :initialized} = state, :set_show) do
    {:ok, %{state | status: :show_set}}
  end

  def check(%BallotState{status: :show_set} = state, :set_show) do
    {:ok, %{state | status: :show_set}}
  end

  def check(%BallotState{status: :show_set} = state, :set_ballot) do
    {:ok, %{state | status: :ballot_set}}
  end

  def check(%BallotState{status: :ballot_set} = state, :set_ballot) do
    {:ok, %{state | status: :ballot_set}}
  end

  def check(%BallotState{status: :voting} = state, :set_ballot) do
    {:ok, %{state | status: :ballot_set}}
  end

  def check(%BallotState{status: :submitted} = state, :set_ballot) do
    {:ok, %{state | status: :ballot_set}}
  end

  def check(%BallotState{status: :ballot_set} = state, :vote) do
    {:ok, %{state | status: :voting}}
  end

  def check(%BallotState{status: :voting} = state, :vote) do
    {:ok, %{state | status: :voting}}
  end

  def check(%BallotState{status: :voting} = state, :submit) do
    {:ok, %{state | status: :submitted}}
  end

  def check(%BallotState{status: :voting} = state, :end_show) do
    {:ok, %{state | status: :show_ended}}
  end

  def check(%BallotState{status: :submitted} = state, :vote) do
    {:ok, %{state | status: :voting}}
  end

  def check(%BallotState{status: :submitted} = state, :submit) do
    {:ok, %{state | status: :submitted}}
  end

  def check(%BallotState{status: :submitted} = state, :get_score) do
    {:ok, state}
  end

  def check(%BallotState{status: :submitted} = state, :end_show) do
    {:ok, %{state | status: :show_ended}}
  end

  def check(%BallotState{status: :show_ended} = state, :get_score) do
    {:ok, state}
  end

  def check(_state, _action), do: :error
end