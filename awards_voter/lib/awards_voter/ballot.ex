defmodule AwardsVoter.Ballot do
  alias __MODULE__
  alias AwardsVoter.{Vote, Show, Category}
  
  require Logger

  defstruct [:voter, :votes]
  @type votemap :: %{required(String.t()) => Vote.t()}
  @type t :: %__MODULE__{voter: String.t(), votes: votemap | nil}

  @spec new(String.t(), nonempty_list(Category.t())) :: {:ok, %Ballot{votes: votemap}}
  def new(voter, [_ | _] = categories) do
    ballot = init_ballot_with_empty_votes(%Ballot{voter: voter}, categories)
    {:ok, ballot}
  end

  @spec new(String.t(), Show.t()) :: {:ok, Ballot.t()}
  def new(voter, show) do
    Ballot.new(voter, show.categories)
  end

  @spec vote(Ballot.t(), String.t(), String.t()) :: {:ok | :invalid_vote, Ballot.t()}
  def vote(ballot, category_name, contestant_name) do
    with {:get_category, %Vote{} = category_vote_entry} <- {:get_category, ballot.votes[category_name]},
         {:do_vote, {:ok, vote}} <- {:do_vote, Vote.vote(category_vote_entry, contestant_name)},
         {:update_ballot, {:ok, updated_ballot}} <- {:update_ballot, update_ballot_with_vote(ballot, vote)} 
    do
      {:ok, updated_ballot}
    else
      {:get_category, nil} ->
        Logger.error("Category (#{category_name}) does not exist in ballot")
        {:invalid_vote, ballot}
      {:do_vote, _} ->
        Logger.error("Invalid or nil argument passed to Vote.vote/2")
        {:invalid_vote, ballot}
      {:update_ballot, e} ->
        Logger.error("Error raised when trying to update ballot: #{inspect e}")
        {:invalid_vote, ballot}
    end
  end

  @spec score(Ballot.t()) :: {:ok, non_neg_integer()}
  def score(ballot) do
    {:ok, Enum.count(ballot.votes, fn {_category_name, vote} -> Vote.is_winning_vote?(vote) end)}
  end

  @spec init_ballot_with_empty_votes(Ballot.t(), nonempty_list(Category.t())) :: %Ballot{votes: votemap}
  def init_ballot_with_empty_votes(ballot, categories) do
    votes = Enum.map(categories, fn category -> Vote.new(category) end)
    %{ballot | votes: Map.new(votes, fn {:ok, vote} -> {vote.category.name, vote} end)}
  end

  @spec update_ballot_with_vote(Ballot.t(), Vote.t()) :: {:ok, Ballot.t()} | {:error, term()}
  defp update_ballot_with_vote(ballot, vote) do
    try do
      {:ok, %{ballot | votes: Map.update!(ballot.votes, vote.category.name, fn _ -> vote end)}}
    rescue
      e -> {:error, e}
    end
  end
end
  