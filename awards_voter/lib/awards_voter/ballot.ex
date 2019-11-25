defmodule AwardsVoter.Ballot do
  alias __MODULE__
  alias AwardsVoter.Vote
  alias AwardsVoter.Show
  alias AwardsVoter.Category

  defstruct [:voter, :votes]
  @type t :: %__MODULE__{voter: String.t(), votes: MapSet.t(Vote.t())}

  @spec new(String.t(), nonempty_list(Categories.t())) :: {:ok, Ballot.t()}
  def new(voter, [_|_] = categories) do
    ballot = init_ballot_with_empty_votes(%Ballot{voter: voter, votes: MapSet.new()}, categories)
    {:ok, ballot}
  end
  
  @spec new(String.t(), Show.t()) :: {:ok, Ballot.t()}
  def new(voter, show) do
    ballot = init_ballot_with_empty_votes(%Ballot{voter: voter, votes: MapSet.new()}, show.categories)
    {:ok, ballot}
  end
  
  @spec init_ballot_with_empty_votes(Ballot.t(), nonempty_list(Category.t())) :: Ballot.t()
  defp init_ballot_with_empty_votes(init_ballot, categories) do
    Enum.reduce(categories, init_ballot, fn category, ballot ->
      existing_votes = ballot.votes
      {:ok, vote} = Vote.new(category)
      %{ballot | votes: MapSet.put(existing_votes, vote)}
    end)
  end
end