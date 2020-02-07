defmodule AwardsVoter.Context.Voting do
  alias __MODULE__
  alias AwardsVoter.Context.Voting.Votes
  alias AwardsVoter.Context.Voting.Ballots
  alias AwardsVoter.Context.Voting.Ballots.Ballot
  alias AwardsVoter.Context.Voting.Votes.Vote
  alias AwardsVoter.Context.Admin.Categories.Category
  
  require Logger

  @spec vote(Ballot.t(), String.t(), String.t()) :: {:ok | :invalid_vote, Ballot.t()}
  def vote(ballot, category_name, contestant_name) do
    with {:get_category_vote, %Vote{} = category_vote_entry} <- {:get_category_vote, Ballots.get_vote_by_category(ballot, category_name)},
         {:do_vote, {:ok, vote}} <- {:do_vote, vote(category_vote_entry, contestant_name)},
         {:update_ballot, {:ok, updated_ballot}} <- {:update_ballot, Ballots.update_ballot_with_vote(ballot, vote)}
      do
      {:ok, updated_ballot}
    else
      {:get_category_vote, nil} ->
        Logger.error("Category (#{category_name}) does not exist in ballot")
        {:invalid_vote, ballot}
      {:do_vote, _} ->
        Logger.error("Invalid or nil argument passed to Voting.vote/2")
        {:invalid_vote, ballot}
      {:update_ballot, e} ->
        Logger.error("Error raised when trying to update ballot: #{inspect e}")
        {:invalid_vote, ballot}
    end
  end

  @spec vote(Vote.t(), String.t()) :: :invalid_category | {:ok, Vote.t()} | {:invalid_vote, Vote.t()}
  def vote(nil, _), do: :error
  def vote(vote, contestant_name) do
    case Enum.find(vote.category.contestants, nil, fn contestant ->
      contestant.name == contestant_name
    end) do
      nil -> {:invalid_vote, vote}
      cont -> {:ok, %{vote | contestant: cont}}
    end
  end

  @spec is_winning_vote?(Vote.t()) :: boolean()
  def is_winning_vote?(%Vote{contestant: nil}), do: false
  def is_winning_vote?(%Vote{category: nil}), do: false
  def is_winning_vote?(%Vote{category: %Category{winner: nil}}), do: false
  def is_winning_vote?(vote) do
    vote.contestant.name == vote.category.winner.name
  end
end