defmodule AwardsVoter.Ballot do
  alias __MODULE__
  alias AwardsVoter.Vote
  alias AwardsVoter.Show
  alias AwardsVoter.Category

  defstruct [:voter, :votes]
  @type t :: %__MODULE__{voter: String.t(), votes: Map.t(Vote.t())}

  @spec new(String.t(), nonempty_list(Categories.t())) :: {:ok, Ballot.t()}
  def new(voter, [_|_] = categories) do
    ballot = init_ballot_with_empty_votes(%Ballot{voter: voter}, categories)
    {:ok, ballot}
  end
  
  @spec new(String.t(), Show.t()) :: {:ok, Ballot.t()}
  def new(voter, show) do
    Ballot.new(voter, show.categories)
  end
  
  @spec init_ballot_with_empty_votes(Ballot.t(), nonempty_list(Category.t())) :: Ballot.t()
  defp init_ballot_with_empty_votes(ballot, categories) do
    votes = Enum.map(categories, fn category -> Vote.new(category) end)
    %{ballot | votes: Map.new(votes, fn {:ok, vote} ->{vote.category.name, vote} end)}
  end
end