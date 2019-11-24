defmodule AwardsVoter.Ballot do
  alias __MODULE__
  alias AwardsVoter.Vote

  defstruct [:voter, :votes]
  @type t :: %__MODULE__{voter: String.t(), votes: nonempty_list(%Vote{})}

  def new(voter \\ nil, votes \\ []) do
    {:ok, %Ballot{voter: voter, votes: votes}}
  end
end