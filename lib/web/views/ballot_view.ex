defmodule AwardsVoter.Web.BallotView do
  use AwardsVoter.Web, :view

  alias AwardsVoter.Context.Models.Vote

  def is_matching_contestant(vote_map, category, contestant) do
    Map.get(vote_map, category.name) == contestant.name
  end

  def get_voted_for_contestant(ballot, category) do
    case Enum.find(ballot.votes, fn vote -> vote.category.name == category.name end) do
      nil -> %{}
      vote_for_category -> Map.get(vote_for_category, :contestant, nil)
    end
  end

  def has_vote?(category, vote_map, ballot) do
    in_vote_map = category.name in Map.keys(vote_map)
    in_ballot = category.name in Enum.map(ballot.votes, fn %Vote{category: category} -> category.name end)
    in_vote_map or in_ballot
  end
end
