defmodule AwardsVoter.Context.Voting.Ballots do
  alias AwardsVoter.Context.Voting.Ballots.Ballot
  alias AwardsVoter.Context.Voting.Votes
  alias AwardsVoter.Context.Voting.Votes.Vote
  alias AwardsVoter.Context.Admin.Shows.Show
  alias AwardsVoter.Context.Admin.Categories.Category
  alias Ecto.Changeset

  @spec create_ballot(map()) :: {:ok, Ballot.t()} | {:errors, Changeset.t()}
  def create_ballot(attrs \\ %{}) do
    cs = Ballot.changeset(%Ballot{}, attrs)
    if cs.valid? do
      {:ok, Changeset.apply_changes(cs)}
    else
      cs = %{cs | action: :create}
      {:errors, cs}
    end
  end
  
  def update_ballot(%Ballot{} = orig_ballot, attrs) do
    cs = Ballot.changeset(orig_ballot, attrs)
    if cs.valid? do
      {:ok, Changeset.apply_changes(cs)}
    else
      cs = %{cs | action: :update}
      {:errors, cs}
    end
  end
  
  @spec create_ballot_from_show_or_catgories(String.t(), %Show{} | list(%Category{})) :: {:ok, Ballot.t()} | {:errors, Changeset.t()}
  def create_ballot_from_show_or_catgories(voter, show_or_categories) do
    votes = get_possible_votes_from_show_or_categories(show_or_categories)
    create_ballot(%{voter: voter, votes: votes})
  end
  
  @spec get_possible_votes_from_show_or_categories(%Show{categories: list(Category.t())}) :: list(Ballot.votemap())
  def get_possible_votes_from_show_or_categories(%Show{} = show) do
    get_possible_votes_from_show_or_categories(show.categories)
  end
  
  @spec get_possible_votes_from_show_or_categories(list(Category.t())) :: list(Ballot.votemap())
  def get_possible_votes_from_show_or_categories([%Category{} | _] = categories) do
    Enum.map(categories, fn category ->
      {:ok, vote} = Votes.create_vote(%{category: category})
      vote
    end)
  end
  
  @spec get_vote_by_category(Ballot.t(), String.t()) :: Vote.t() | nil
  def get_vote_by_category(ballot, category_name) do
    Enum.find(ballot.votes, fn vote -> vote.category.name == category_name end)
  end

  @spec update_ballot_with_vote(Ballot.t(), Vote.t()) :: Ballot.t()
  def update_ballot_with_vote(ballot, vote) do
    category = vote.category
    updated_votes = Enum.map(ballot.votes, fn 
      %Vote{category: ^category} -> vote
      unchanged_vote -> unchanged_vote
    end)
    update_ballot(ballot, %{votes: updated_votes})
  end
end
