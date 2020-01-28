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

  defdelegate list_shows, to: Shows

  defdelegate get_show_by_name(name), to: Shows

  defdelegate create_show(show_map), to: Shows

  defdelegate update_show(original_show, show_map), to: Shows

  defdelegate delete_show(show), to: Shows

  defdelegate change_show(show), to: Shows

  def add_category_to_show(show_name, category_map) do
    with {:ok, show} <- Shows.get_show_by_name(show_name), 
         {:ok, _category} <- Categories.create_category(category_map),
         updated_show <- put_in(show.categories, [category_map | show.categories]) do
      Shows.update_show(show, show_to_map(updated_show))
    else
      {:errors, cs} -> {:errors, cs}
      _ -> :failed_to_add
    end
  end

  def update_show_category(show_name, category_name, new_category_map) do
    with {:ok, show} <- Shows.get_show_by_name(show_name),
         %Category{} = old_category <- Enum.find(show.categories, fn cat -> cat.name == category_name end),
         {:ok, updated_category} <- Categories.update_category(old_category, new_category_map) do
      updated_categories = show.categories
                           |> Enum.map(fn
        %{name: ^category_name} -> category_to_map(updated_category)
        non_matching_category -> category_to_map(non_matching_category)
      end)
      Shows.update_show(show, %{categories: updated_categories})
    end
  end

  def delete_show_category(show_name, category_name) do
    with {:ok, show} <- Shows.get_show_by_name(show_name),
         updated_category_list <- Enum.filter(show.categories, fn %{name: name} -> name != category_name end)
                                  |> Enum.map(&category_to_map/1) do
      Shows.update_show(show, %{categories: updated_category_list})
    end
  end

  def add_contestant_to_show_category(show_name, category_name, contestant_map) do
    with {:ok, show} <- Shows.get_show_by_name(show_name),
         %Category{} = category <- Enum.find(show.categories, fn cat -> cat.name == category_name end),
         {:ok, _contestant} <- Contestants.create_contestant(contestant_map),
         updated_category <- put_in(category.contestants, [contestant_map | category.contestants]),
         updated_categories <- show.categories |> Enum.map(fn
                                                    %{name: ^category_name} -> category_to_map(updated_category)
                                                    non_matching_category -> category_to_map(non_matching_category)
                                                  end) do
      Shows.update_show(show, %{categories: updated_categories})
    end
  end
  
  #  def update_contestant_in_show_category
  
  def delete_contestant_from_show_category(show_name, category_name, contestant_name) do
    with {:ok, show} <- Shows.get_show_by_name(show_name),
         %Category{} = category <- Enum.find(show.categories, fn cat -> cat.name == category_name end),
         updated_category = %{category | contestants: Enum.filter(category.contestants, fn con -> con.name != contestant_name end)},
         updated_categories <- show.categories |> Enum.map(fn
           %{name: ^category_name} -> category_to_map(updated_category)
           non_matching_category -> category_to_map(non_matching_category)
         end) do
      Shows.update_show(show, %{categories: updated_categories})
    end
  end
  
  #  def set_winner_for_show_category

  def contestant_to_map(%Contestant{} = contestant), do: Map.from_struct(contestant)
  def contestant_to_map(%{} = contestant), do: contestant
  def contestant_to_map(nil), do: nil

  def category_to_map(%Category{} = category) do
    category_map = Map.from_struct(category)
    %{category_map | winner: contestant_to_map(category.winner), contestants: Enum.map(category.contestants, &contestant_to_map/1)}
  end
  def category_to_map(%{} = category), do: category
  def category_to_map(nil), do: nil

  def show_to_map(%Show{} = show) do
    show_map = Map.from_struct(show)
    %{show_map | categories: Enum.map(show.categories, &show_to_map/1)}
  end
  def show_to_map(%{} = show), do: show
  def show_to_map(nil), do: nil
end