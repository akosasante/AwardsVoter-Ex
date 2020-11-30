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

  def save_show(show) do
    ShowTable.save([{show.id, show}])
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
         {:changeset_valid?, %{valid?: true}} <- {:changeset_valid?, Show.to_changeset(updated_show)}
    do
      updated_show
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

  def update_show_category(show, original_category, updated_category_map) do
    with {:ok, updated_category} <- Category.update(original_category, updated_category_map),
         category_name when is_not_nil(category_name) <- Map.get(original_category, :name),
         {:matching_category, matching_category} when is_not_nil(matching_category) <-
           {:matching_category, get_category_by_name(show, category_name)},
         updated_show_categories <- Enum.map(show.categories, fn
           %Category{name: ^category_name} -> updated_category
           non_matching_category -> non_matching_category
         end),
         updated_show <- Map.put(show, :categories, updated_show_categories),
         {:changeset_valid?, %{valid?: true}} <- {:changeset_valid?, Show.to_changeset(updated_show)}
      do
      updated_show
    else
      {:matching_category, nil} ->
        Logger.error("Could not find category matching #{inspect original_category} in show=#{inspect show}")
        :error
      {:changeset_valid?, changeset} ->
        Logger.error("Updated show changeset was invalid. Changeset=#{inspect changeset}")
        :error
      error ->
        Logger.error("Unexpected error occurred while setting winner for show. Error=#{inspect error}. Show=#{inspect show}")
        :error
    end
  end

  def update_show_contestant(show, category_name, original_contestant, updated_contestant_map) do
    with {:ok, updated_contestant} <- Contestant.update(original_contestant, updated_contestant_map),
         contestant_name when is_not_nil(contestant_name) <- Map.get(original_contestant, :name),
         {:matching_category, matching_category} when is_not_nil(matching_category) <-
           {:matching_category, get_category_by_name(show, category_name)},
         {:matching_contestant, matching_contestant} when is_not_nil(matching_contestant) <- {:matching_contestant, get_contestant_by_name(matching_category, contestant_name)},
         updated_category_contestants <- Enum.map(matching_category.contestants, fn
              %Contestant{name: ^contestant_name} -> updated_contestant
           non_matching_contestant -> non_matching_contestant
         end),
         updated_category <- Map.put(matching_category, :contestants, updated_category_contestants),
         updated_show_categories <- Enum.map(show.categories, fn
           %Category{name: ^category_name} -> updated_category
           non_matching_category -> non_matching_category
         end),
         updated_show <- Map.put(show, :categories, updated_show_categories),
         {:changeset_valid?, %{valid?: true}} <- {:changeset_valid?, Show.to_changeset(updated_show)}
      do
        updated_show
      else
      {:matching_contestant, nil} ->
          Logger.error("Could not find contestant matching #{inspect original_contestant} in show=#{inspect show}")
          :error
      {:matching_category, nil} ->
        Logger.error("Could not find category matching #{inspect category_name}")
        :error
      {:changeset_valid?, changeset} ->
        Logger.error("Updated show changeset was invalid. Changeset=#{inspect changeset}")
        :error
      error ->
        Logger.error("Unexpected error occurred while setting winner for show. Error=#{inspect error}. Show=#{inspect show}")
        :error
    end
  end

  def get_category_by_name(%Show{} = show, category_name) do
    Enum.find(show.categories, fn category -> category.name == category_name end)
  end

  def get_contestant_by_name(%Show{} = show, category_name, contestant_name) do
    category = get_category_by_name(show, category_name)
    get_contestant_by_name(category, contestant_name)
  end

  def get_contestant_by_name(%Category{} = category, contestant_name) do
    Enum.find(category.contestants, fn contestant -> contestant.name == contestant_name end)
  end

  def remove_category_from_show(%Show{} = show, %Category{name: category_name} = category), do: remove_category_from_show(show, category_name)

  def remove_category_from_show(%Show{categories: categories} = show, category_name) do
    updated_categories = Enum.reject(categories, fn category -> category.name == category_name end)
    Map.put(show, :categories, updated_categories)
  end

  def remove_contestant_from_show(show, %Category{contestants: contestants} = category, contestant_name) do
    updated_contestants = Enum.reject(contestants, fn contestant -> contestant.name == contestant_name end)
    updated_category = Map.put(category, :contestants, updated_contestants)
    update_show_category(show, category, Category.to_map(updated_category))
  end

  def remove_contestant_from_show(%Show{} = show, category_name, contestant_name) when is_binary(category_name) and is_binary(contestant_name) do
    category = get_category_by_name(show, category_name)
    remove_contestant_from_show(show, category, contestant_name)
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
