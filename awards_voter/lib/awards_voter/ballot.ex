defmodule AwardsVoter.Ballot do
  alias __MODULE__
  alias AwardsVoter.Vote

  defstruct [:voter, :votes]
  @type t :: %__MODULE__{voter: String.t(), votes: MapSet.t(Vote.t())}

  def new(voter \\ nil, votes \\ MapSet.new()) do
    {:ok, %Ballot{voter: voter, votes: votes}}
  end
end