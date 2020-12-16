defmodule AwardsVoter.Web.BallotView do
  use AwardsVoter.Web, :view

  def is_matching_contestant(vote_map, category, contestant) do
    Map.get(vote_map, category.name) == contestant.name
  end

end
