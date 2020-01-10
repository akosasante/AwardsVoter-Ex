defmodule AwardsVoter.Show do
  alias __MODULE__
  alias AwardsVoter.{Category, ShowManager}
  
  require Logger

  @enforce_keys [:name]
  defstruct [:name, :categories]
  @type t :: %__MODULE__{name: String.t(), categories: nonempty_list(Category.t())}
  @type show_tuple :: {String.t(), Show.t()}

  @spec new(String.t(), list(Category.t())) :: {:ok, Show.t()}
  def new(name, categories \\ []) do
    struct_categories = Enum.map(categories, fn 
      %Category{} = category -> category
      category_map -> 
        {:ok, category} = Category.new(Map.get(category_map, :name), Map.get(category_map, :contestants, []), Map.get(category_map, :description), Map.get(category_map, :winner)) 
        category
    end)
    {:ok, %Show{name: name, categories: struct_categories}}
  end

  @spec save_or_update_shows([Show.t()] | Show.t(), module()) :: {:ok, [Show.t()]} | :error_saving
  def save_or_update_shows(show_or_shows,  show_manager_mod \\ ShowManager)
  
  def save_or_update_shows(shows, show_manager_mod) when is_list(shows) do
    show_tuples = Enum.map(shows, &({Map.get(&1, :name), &1}))
    insert_show_tuples(show_tuples, false, show_manager_mod)
  end
  
  def save_or_update_shows(show, show_manager_mod) do
    insert_show_tuples([{show.name, show}], true, show_manager_mod)
  end
  
  @spec get_show_by_name(String.t(), module()) :: {:ok, Show.t()} | :not_found | :error_finding
  def get_show_by_name(name, show_manager_mod \\ ShowManager) do
    case show_manager_mod.get(name) do
      :not_found -> :not_found
      {:error, reason} -> 
        Logger.error("Due to #{inspect reason} failed to lookup show #{name}")
        :error_finding
      show -> {:ok, show}
    end
  end
  
  @spec delete_show_entry(String.t(), module()) :: :ok | :error_deleting
  def delete_show_entry(name, show_manager_mod \\ ShowManager) do
    case show_manager_mod.delete(name) do
      {:error, reason} ->
        Logger.error("Due to #{inspect reason} failed to delete show #{name}")
        :error_deleting
      :ok -> :ok
    end
  end

  @spec insert_show_tuples(nonempty_list(Show.show_tuple()), boolean(), module()) :: {:ok, nonempty_list(Show.t())} | :error_saving
  defp insert_show_tuples(show_tuples, single?, show_manager_mod) do
    shows = Enum.map(show_tuples, fn {_name, show} -> show end)
    case show_manager_mod.put(show_tuples) do
      :ok ->
        if single? do
          {:ok, shows |> hd}
        else
          {:ok, shows}
        end
      {:error, e} ->
        Logger.error("Due to #{inspect e} failed to save shows (#{inspect shows}")
        :error_saving
    end
  end
end
