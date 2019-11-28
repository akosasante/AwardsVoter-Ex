defmodule AwardsVoter.BallotState do
  alias __MODULE__

  defstruct status: :initialized

  @type t :: %__MODULE__{
          status: :initialized | :show_set | :ballot_set | :voting | :submitted | :show_ended
        }

  @spec new() :: BallotState.t()
  def new(), do: %BallotState{}

  @spec check(BallotState.t(), atom()) :: {:ok, BallotState.t()}
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

  def check(%BallotState{status: :ballot_set} = state, :vote) do
    {:ok, %{state | status: :voting}}
  end

  def check(%BallotState{status: :voting} = state, :vote) do
    {:ok, %{state | status: :voting}}
  end

  def check(%BallotState{status: :voting} = state, :submit) do
    {:ok, %{state | status: :submitted}}
  end

  def check(%BallotState{status: :submitted} = state, :revote) do
    {:ok, %{state | status: :voting}}
  end

  def check(%BallotState{status: :submitted} = state, :submit) do
    {:ok, %{state | status: :submitted}}
  end

  def check(%BallotState{status: :voting} = state, :end_show) do
    {:ok, %{state | status: :show_ended}}
  end

  def check(%BallotState{status: :submitted} = state, :end_show) do
    {:ok, %{state | status: :show_ended}}
  end

  def check(_state, _action), do: :error
end
