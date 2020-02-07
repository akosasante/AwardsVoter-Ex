defmodule AwardsVoter.Context.Voting.Ballots do
  alias AwardsVoter.Context.Voting.Ballots.Ballot
  alias AwardsVoter.Context.Voting.Votes
  alias AwardsVoter.Context.Admin.Shows.Show
  alias AwardsVoter.Context.Admin.Categories.Category
  alias Ecto.Changeset

  def create_ballot(attrs \\ %{}) do
    cs = Ballot.changeset(%Ballot{}, attrs)
    if cs.valid? do
      {:ok, Changeset.apply_changes(cs)}
    else
      cs = %{cs | action: :create}
      {:errors, cs}
    end
  end
  
  def create_ballot_from_show_or_catgories(voter, show_or_categories) do
    votes = get_possible_votes_from_show_or_categories(show_or_categories)
    create_ballot(%{voter: voter, votes: votes})
  end
  
  @spec get_possible_votes_from_show_or_categories(list(Category.t()) | %Show{categories: list(Category.t())}) :: list(Ballot.votemap())
  def get_possible_votes_from_show_or_categories(%Show{} = show) do
    get_possible_votes_from_show_or_categories(show.categories)
  end
  
  def get_possible_votes_from_show_or_categories([%Category{} | _] = categories) do
    Enum.map(categories, fn category ->
      {:ok, vote} = Votes.create_vote(%{category: category})
      vote
    end)
  end
end
