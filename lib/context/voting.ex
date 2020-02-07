defmodule AwardsVoter.Context.Voting do
  alias __MODULE__
  alias AwardsVoter.Context.Voting.Votes.Vote
  alias AwardsVoter.Context.Admin.Categories.Category

  @spec is_winning_vote?(Vote.t()) :: boolean()
  def is_winning_vote?(%Vote{contestant: nil}), do: false
  def is_winning_vote?(%Vote{category: nil}), do: false
  def is_winning_vote?(%Vote{category: %Category{winner: nil}}), do: false
  def is_winning_vote?(vote) do
    vote.contestant.name == vote.category.winner.name
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
end