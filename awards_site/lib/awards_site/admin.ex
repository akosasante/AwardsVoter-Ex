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
  
  def update_show_category(show, category) do
    
  end
end