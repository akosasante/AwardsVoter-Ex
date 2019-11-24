defmodule AwardsVoter.Ballot do
  alias __MODULE__

  defstruct [:voter, :votes]
  @type t :: %__MODULE__{voter: String.t(), votes: list()}

  def new(voter \\ nil, votes \\ []) do
    {:ok, %Ballot{voter: voter, votes: votes}}
  end
end