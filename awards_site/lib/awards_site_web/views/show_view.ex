defmodule AwardsSiteWeb.ShowView do
  use AwardsSiteWeb, :view
  
  def list_of_keys(list, key) do
    list
    |> Enum.map(&(Map.get(&1, key)))
    |> Enum.join(", ")
  end
end
