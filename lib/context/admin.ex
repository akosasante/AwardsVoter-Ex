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

  require Logger

  defguard is_not_nil(value) when not(is_nil(value))

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
         show <- Show.add_id(show),
         :ok <- ShowTable.save([{show.id, show}]) do
      show
    end
  end

  def delete_show(show_id) do
    ShowTable.delete(show_id)
  end

  def set_category_winner(show, category_name, winner_name) do
    with {:matching_category, matching_category} when is_not_nil(matching_category) <-
           {:matching_category, Enum.find(show.categories, fn category -> category.name == category_name end)},
         {:matching_winner, category_winning_contestant} when is_not_nil(category_winning_contestant)  <-
           {:matching_winner, Enum.find(matching_category.contestants, fn contestant -> contestant.name == winner_name end)},
         updated_category <- Map.put(matching_category, :winner, category_winning_contestant),
         updated_show_categories <- Enum.map(show.categories, fn
           %Category{name: ^category_name} -> updated_category
           non_matching_category -> non_matching_category
         end),
         updated_show <- Map.put(show, :categories, updated_show_categories),
         {:changeset_valid?, %{valid?: true}} <- {:changeset_valid?, Show.to_changeset(updated_show)},
         :ok <- ShowTable.save([{updated_show.id, updated_show}])
    do
      :ok
    else
      {:matching_category, nil} ->
        Logger.error("Could not find category matching #{category_name} in show=#{inspect show}")
        :error
      {:matching_winner, nil} ->
        Logger.error("Could not find contestant matching #{winner_name} in show=#{inspect show}")
        :error
      {:changeset_valid?, changeset} ->
        Logger.error("Updated show changeset was invalid. Changeset=#{inspect changeset}")
        :error
      error ->
        Logger.error("Unexpected error occured while setting winner for show. Error=#{inspect error}. Show=#{inspect show}")
        :error
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
