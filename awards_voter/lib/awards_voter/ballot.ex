defmodule AwardsVoter.Ballot do
  alias __MODULE__
  alias AwardsVoter.{Vote, Show, Category}

  defstruct [:voter, :votes]
  @type t :: %__MODULE__{voter: String.t(), votes: Map.t(Vote.t())}

  @spec new(String.t(), nonempty_list(Categories.t())) :: {:ok, Ballot.t()}
  def new(voter, [_ | _] = categories) do
    ballot = init_ballot_with_empty_votes(%Ballot{voter: voter}, categories)
    {:ok, ballot}
  end

  @spec new(String.t(), Show.t()) :: {:ok, Ballot.t()}
  def new(voter, show) do
    Ballot.new(voter, show.categories)
  end

  @spec vote(Ballot.t(), String.t(), String.t()) :: {atom(), Ballot.t()} | {:error, String.t()}
  def vote(ballot, category_name, contestant_name) do
    case Vote.vote(ballot.votes[category_name], contestant_name) do
      {:ok, vote} -> update_ballot_with_vote!(ballot, vote)
      _ -> {:invalid_vote, ballot}
    end
  end

  @spec score(Ballot.t()) :: non_neg_integer()
  def score(ballot) do
    Enum.count(ballot.votes, fn {_category_name, vote} -> Vote.is_winning_vote?(vote) end)
  end

  @spec init_ballot_with_empty_votes(Ballot.t(), nonempty_list(Category.t())) :: Ballot.t()
  defp init_ballot_with_empty_votes(ballot, categories) do
    votes = Enum.map(categories, fn category -> Vote.new(category) end)
    %{ballot | votes: Map.new(votes, fn {:ok, vote} -> {vote.category.name, vote} end)}
  end

  defp update_ballot_with_vote!(ballot, vote) do
    try do
      {:ok, %{ballot | votes: Map.update!(ballot.votes, vote.category.name, fn _ -> vote end)}}
    rescue
      KeyError -> {:invalid_category, ballot}
      e -> {:error, inspect(e)}
    end
  end
end
