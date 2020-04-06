defmodule AwardsVoter.Context.Admin do
  @moduledoc """
  Deals with modifying and creating shows and their constituents
  """

  alias AwardsVoter.Context.Admin.Shows
  alias AwardsVoter.Context.Admin.Categories
  alias AwardsVoter.Context.Admin.Categories.Category
  alias AwardsVoter.Context.Admin.Shows.Show
  alias AwardsVoter.Context.Admin.Contestants
  alias AwardsVoter.Context.Admin.Contestants.Contestant
  alias AwardsVoter.Context.Voting

  @doc """
  Returns the list of shows.

  ## Examples

      iex> list_shows()
      {:ok, [%Show{}, ...]}

  """
  defdelegate list_shows, to: Shows

  defdelegate get_show_by_name(name), to: Shows

  defdelegate create_show(show_map), to: Shows

  defdelegate update_show(original_show, show_map), to: Shows

  defdelegate delete_show(show), to: Shows

  defdelegate change_show(show), to: Shows

  defdelegate change_category(category), to: Categories

  defdelegate change_contestant(contestant), to: Contestants

  ### Category Methods

  @spec get_category_from_show(String.t(), String.t()) :: {:ok, Category.t()} | :category_not_found | term()
  def get_category_from_show(show_name, category_name) do
    with {:show, {:ok, show}} <- {:show, Shows.get_show_by_name(show_name)},
         %Category{} = category <- Enum.find(show.categories, fn cat -> cat.name == category_name end) do
      {:ok, category}
    else
      {:show, _e} -> :show_not_found
      nil -> :category_not_found
      e -> e
    end
  end

  @spec add_category_to_show(String.t(), map()) :: Shows.change_result() | :failed_to_add
  def add_category_to_show(show_name, category_map) do
    with {:show, {:ok, show}} <- {:show, Shows.get_show_by_name(show_name)},
         {:ok, _category} <- Categories.create_category(category_map),
         updated_categories <- [category_map | show.categories |> Enum.map(&category_to_map/1)] do
      update_show_and_ballots(show, updated_categories)
    else
      {:show, _e} -> :show_not_found
      {:errors, cs} -> {:errors, cs}
      e -> e
    end
  end

  @spec update_show_category(String.t(), String.t(), map()) :: Shows.change_result()
  def update_show_category(show_name, category_name, new_category_map) do
    with {:show, {:ok, show}} <- {:show, Shows.get_show_by_name(show_name)},
         %Category{} = old_category <- Enum.find(show.categories, fn cat -> cat.name == category_name end),
         {:ok, updated_category} <- Categories.update_category(old_category, new_category_map) do
      updated_categories = show.categories
                           |> Enum.map(fn
        %{name: ^category_name} -> category_to_map(updated_category)
        non_matching_category -> category_to_map(non_matching_category)
      end)
      update_show_and_ballots(show, updated_categories)
    else
      {:show, _e} -> :show_not_found
      nil -> :category_not_found
      {:errors, cs} -> {:errors, cs}
      e -> e
    end
  end

  @spec delete_show_category(String.t(), String.t()) :: Shows.change_result()
  def delete_show_category(show_name, category_name) do
    with {:show, {:ok, show}} <- {:show, Shows.get_show_by_name(show_name)},
         updated_category_list <- Enum.filter(show.categories, fn %{name: name} -> name != category_name end)
                                  |> Enum.map(&category_to_map/1) do
      count_before = Enum.count(show.categories)
      if count_before == Enum.count(updated_category_list) do
        :category_not_found
      else
        update_show_and_ballots(show, updated_category_list)
      end
    else
      {:show, _e} -> :show_not_found
      e -> e
    end
  end

  #### Contestant Methods

  @spec get_contestant_from_show(String.t(), String.t(), String.t()) :: {:ok, Contestant.t()} | :category_not_found | :contestant_not_found | term()
  def get_contestant_from_show(show_name, category_name, name) do
    with {:show, {:ok, show}} <- {:show, Shows.get_show_by_name(show_name)},
         {:category, %Category{} = category} <- {:category, Enum.find(show.categories, fn cat -> cat.name == category_name end)},
         {:contestant, %Contestant{} = contestant} <-
           {:contestant, Enum.find(category.contestants, fn cont -> cont.name == name end)} do
      {:ok, contestant}
    else
      {:show, _e} -> :show_not_found
      {:category, nil} -> :category_not_found
      {:contestant, nil} -> :contestant_not_found
      e -> e
    end
  end

  @spec add_contestant_to_show_category(String.t(), String.t(), map()) :: Shows.change_result()
  def add_contestant_to_show_category(show_name, category_name, contestant_map) do
    with {:show, {:ok, show}} <- {:show, Shows.get_show_by_name(show_name)},
         %Category{} = category <- Enum.find(show.categories, fn cat -> cat.name == category_name end),
         {:ok, _contestant} <- Contestants.create_contestant(contestant_map),
         updated_category <- put_in(category.contestants, [contestant_map | category.contestants]),
         updated_categories <- show.categories |> Enum.map(fn
                                                    %{name: ^category_name} -> category_to_map(updated_category)
                                                    non_matching_category -> category_to_map(non_matching_category)
                                                  end) do
      update_show_and_ballots(show, updated_categories)
    else
      {:show, _e} -> :show_not_found
      nil -> :category_not_found
      e -> e
    end
  end

  @spec update_contestant_in_show_category(String.t(), String.t(), String.t(), map()) :: Shows.change_result()
  def update_contestant_in_show_category(show_name, category_name, contestant_name, new_contestant_map) do
    with {:show, {:ok, show}} <- {:show, Shows.get_show_by_name(show_name)},
         {:category, %Category{} = category} <- {:category, Enum.find(show.categories, fn cat -> cat.name == category_name end)},
         {:contestant, %Contestant{} = old_contestant} <- {:contestant, Enum.find(category.contestants, fn cont -> cont.name == contestant_name end)},
         {:ok, updated_contestant} <- Contestants.update_contestant(old_contestant, new_contestant_map),
         updated_contestants <- category.contestants
                                |> Enum.map(fn
                                  %{name: ^contestant_name} -> contestant_to_map(updated_contestant)
                                  non_matching_category -> contestant_to_map(non_matching_category)
                                end),
         updated_categories <- show.categories
                           |> Enum.map(fn
           %{name: ^category_name} = category -> category_to_map(%{category | contestants: updated_contestants})
           non_matching_category -> category_to_map(non_matching_category)
         end) do
      update_show_and_ballots(show, updated_categories)
    else
      {:show, _e} -> :show_not_found
      {:category, nil} -> :category_not_found
      {:contestant, nil} -> :contestant_not_found
      e -> e
    end
  end

  @spec delete_contestant_from_show_category(String.t(), String.t(), String.t()) :: Shows.change_result()
  def delete_contestant_from_show_category(show_name, category_name, contestant_name) do
    with {:show, {:ok, show}} <- {:show, Shows.get_show_by_name(show_name)},
         {:category, %Category{} = category} <- {:category, Enum.find(show.categories, fn cat -> cat.name == category_name end)},
         updated_category <- update_category_after_contestant_delete(category, contestant_name),
         updated_categories <- show.categories |> Enum.map(fn
           %{name: ^category_name} -> category_to_map(updated_category)
           non_matching_category -> category_to_map(non_matching_category)
         end) do
      count_before = Enum.count(category.contestants)
      if count_before == Enum.count(updated_category.contestants) do
        :contestant_not_found
      else
        update_show_and_ballots(show, updated_categories)
      end
    else
      {:show, _e} -> :show_not_found
      {:category, nil} -> :category_not_found
      e -> e
    end
  end

  @spec set_winner_for_show_category(String.t(), String.t(), String.t()) :: Shows.change_result() | :invalid_winner | term()
  def set_winner_for_show_category(show_name, category_name, winner_name) do
    with {:show, {:ok, show}} <- {:show, Shows.get_show_by_name(show_name)},
         {:category, %Category{} = category} <- {:category, Enum.find(show.categories, fn cat -> cat.name == category_name end)},
         {:contestant, %Contestant{} = winner} <- {:contestant,
           Enum.find(category.contestants, fn cont -> cont.name == winner_name end)},
         updated_category = %{category | winner: winner},
         updated_categories <- show.categories |> Enum.map(fn
           %{name: ^category_name} -> category_to_map(updated_category)
           non_matching_category -> category_to_map(non_matching_category)
         end) do
      update_show_and_ballots(show, updated_categories)
    else
      {:show, _e} -> :show_not_found
      {:category, nil} -> :category_not_found
      {:contestant, nil} -> :invalid_winner
      e -> e
    end
  end

  ### Struct To Map

  @spec contestant_to_map(Contestant.t() | map() | nil) :: map()
  def contestant_to_map(%Contestant{} = contestant), do: Map.from_struct(contestant)
  def contestant_to_map(%{} = contestant), do: contestant
  def contestant_to_map(nil), do: nil

  @spec category_to_map(Category.t() | map() | nil) :: map()
  def category_to_map(%Category{} = category) do
    category_map = Map.from_struct(category)
    %{category_map |
      winner: contestant_to_map(category.winner),
      contestants: Enum.map(category.contestants, &contestant_to_map/1)}
  end
  def category_to_map(%{} = category), do: category
  def category_to_map(nil), do: nil

  @spec show_to_map(Show.t() | map() | nil) :: map()
  def show_to_map(%Show{} = show) do
    show_map = Map.from_struct(show)
    %{show_map | categories: Enum.map(show.categories, &category_to_map/1)}
  end
  def show_to_map(%{} = show), do: show
  def show_to_map(nil), do: nil

  ###############################################

  defp update_show_and_ballots(orig_show, updated_categories) do
    {:ok, show} = Shows.update_show(orig_show, %{categories: updated_categories})
    Voting.update_ballots_for_show(show)
    {:ok, show}
  end

  defp update_category_after_contestant_delete(category, contestant_name) do
    updated_category = %{category | contestants: Enum.filter(category.contestants,
      fn con -> con.name != contestant_name end)}
    cond do
      is_nil(category.winner) -> updated_category
      category.winner.name == contestant_name -> %{ updated_category | winner: nil }
      true -> updated_category
    end
  end
end