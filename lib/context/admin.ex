defmodule AwardsVoter.Context.Admin do
  @moduledoc """
  Deals with modifying and creating shows and their constituents
  """

  alias AwardsVoter.Context.Models.Show
  alias AwardsVoter.Context.Tables.ShowTable
  alias AwardsVoter.Context.Models.Category
  alias AwardsVoter.Context.Models.Contestant
  alias AwardsVoter.Context.Models.Vote
  alias AwardsVoter.Context.Models.Ballot

  defdelegate show_changeset(show), to: Show, as: :to_changeset
  defdelegate category_changeset(category), to: Category, as: :to_changeset
  defdelegate contestant_changeset(contestant), to: Contestant, as: :to_changeset
  defdelegate vote_changeset(vote), to: Vote, as: :to_changeset
  defdelegate ballot_changeset(ballot), to: Ballot, as: :to_changeset

  def get_all_shows() do
    ShowTable.all()
  end

  def get_show_by_id(id) do
    ShowTable.get(id)
  end

  def create_show(show_map) do
    with {:ok, show} <- Show.create(show_map),
         :ok <- ShowTable.save([{show.id, show}]) do
      show
    end
  end
#  def update_show(show, show_map)
#  def delete_show(show)
#
#  def get_ballot_for_voter_and_show(voter, show)
#  def create_new_ballot(ballot_map)
#  def update_ballot(ballot, ballot_map)
#  def score_ballot(ballot)
#  def get_scores_for_show(show_id)

end
