defmodule AwardsVoter.Show do
  alias __MODULE__
  alias AwardsVoter.Category

  @enforce_keys [:name]
  defstruct [:name, :categories]
  @type t :: %__MODULE__{name: String.t(), categories: nonempty_list(Category.t())}

  @spec new(String.t(), list(Category.t())) :: {:ok, Show.t()}
  def new(name, categories \\ []) do
    struct_categories = Enum.map(categories, fn 
      %Category{} = category -> category
      category_map -> 
        {:ok, category} = Category.new(Map.get(category_map, :name), Map.get(category_map, :contestants), Map.get(category_map, :winner)) 
        category
    end)
    {:ok, %Show{name: name, categories: struct_categories}}
  end

  @spec save_or_update_shows([Show.t()]) :: {:ok, [Show.t()]}
  def save_or_update_shows(shows) when is_list(shows) do
    show_tuples = Enum.map(shows, &({Map.get(&1, :name), &1}))
    case :dets.insert(:shows, show_tuples) do
      :ok -> {:ok, shows}
      {:error, e} -> raise "Failed to save shows due to #{inspect e}"
    end
  end
  
  @spec save_or_update_shows(Show.t()) :: {:ok, Show.t()}
  def save_or_update_shows(show) do
    case :dets.insert(:shows, {show.name, show}) do
      :ok -> {:ok, show}
      {:error, e} -> raise "Failed to save show due to #{inspect e}"
    end
  end
end
