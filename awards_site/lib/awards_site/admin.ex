defmodule AwardsSite.Admin do
  @moduledoc """
  Deals with modifying and creating shows and their constituents
  """
  
  alias AwardsSite.Admin.Shows
  alias AwardsSite.Admin.Categories
  alias AwardsSite.Admin.Categories.Category
  
  def get_all_shows, do: Shows.list_shows()
  
  def get_show_by_name(name), do: Shows.get_show!(name)
  
  def create_sow(show_map), do: Shows.create_show(show_map)
  
  def update_show(original_show, show_map), do: Shows.update_show(original_show, show_map)
  
  def delete_show(show), do: Shows.delete_show(show)
  
  def change_show(show), do: Shows.change_show(show)
  
  def add_category_to_show(show, category_map) do
    with {:ok, _category} <- Categories.create_category(category_map),
         updated_show <- put_in(show.categories, [category_map | show.categories]) do
      Shows.update_show(show, Map.from_struct(updated_show))
    else
      {:errors, cs} -> {:errors, cs}
      _ -> :failed_to_add
    end
  end
  
  def update_show_category(show, old_category, new_category_map) do
    name = old_category.name
    with {:ok, updated_category} <- Categories.update_category(old_category, new_category_map) do
      updated_categories = show.categories
      |> Enum.map(fn 
        %{name: ^name} -> Map.from_struct(updated_category)
        non_matching_category -> Map.from_struct(non_matching_category)
      end)
      Shows.update_show(show, %{categories: updated_categories})
    end
  end
  
  def delete_show_category(show, category) do
    updated_category_list = Enum.filter(show.categories, fn %{name: name} -> name != category.name end)
    Shows.update_show(show, %{categories: updated_category_list})
  end
end