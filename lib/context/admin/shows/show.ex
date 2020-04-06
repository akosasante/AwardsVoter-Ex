defmodule AwardsVoter.Context.Admin.Shows.Show do
  use Ecto.Schema
  import Ecto.Changeset
  require Logger

  alias __MODULE__
  alias AwardsVoter.Context.Admin.Categories.Category
  alias AwardsVoter.Context.Admin.Shows.ShowManager

  @derive {Phoenix.Param, key: :name}
  @primary_key false

  @type t :: %__MODULE__{name: String.t() | nil, categories: list(Category.t())}
  @type show_tuple :: {String.t(), Show.t()}

  embedded_schema do
    field :name, :string
    embeds_many :categories, Category, on_replace: :delete
  end

  @spec changeset(Show.t(), map())  :: Ecto.Changeset.t()
  def changeset(show, attrs) do
    show
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> cast_embed(:categories)
  end

  @spec save_or_update_shows([Show.t()] | Show.t()) :: {:ok, [Show.t()]} | :error_saving
  def save_or_update_shows(shows) when is_list(shows) do
    show_tuples = Enum.map(shows, &({Map.get(&1, :name), &1}))
    insert_show_tuples(show_tuples, false, show_manager_mod())
  end

  def save_or_update_shows(show) do
    insert_show_tuples([{show.name, show}], true, show_manager_mod())
  end

  @spec get_show_by_name(String.t()) :: {:ok, Show.t()} | :not_found | :error_finding
  def get_show_by_name(name) do
    case show_manager_mod().get(name) do
      :not_found -> :not_found
      {:error, reason} ->
        Logger.error("Due to #{inspect reason} failed to lookup show #{name}")
        :error_finding
      show -> {:ok, show}
    end
  end

  @spec get_all_shows() :: {:ok, list(Show.t())} | :error_fetching
  def get_all_shows() do
    case show_manager_mod().all() do
      {:error, reason} ->
        Logger.error("Due to #{inspect reason} failed to fetch all shows in DETS table")
        :error_fetching
      :"$end_of_table" -> {:ok, []}
      show_tuples ->
        shows = Enum.map(show_tuples, fn {_name, show} -> show end)
        {:ok, shows}
    end
  end

  @spec delete_show_entry(String.t()) :: :ok | :error_deleting
  def delete_show_entry(name) do
    case show_manager_mod().delete(name) do
      {:error, reason} ->
        Logger.error("Due to #{inspect reason} failed to delete show #{name}")
        :error_deleting
      :ok -> :ok
    end
  end

  @spec insert_show_tuples(nonempty_list(Show.show_tuple()), boolean(), module()) :: {:ok, nonempty_list(Show.t())} | :error_saving
  defp insert_show_tuples(show_tuples, single?, show_manager_mod) do
    shows = Enum.map(show_tuples, fn {_name, show} -> show end)
    Logger.info "Saving #{Enum.count(shows)} show(s)"
    case show_manager_mod().put(show_tuples) do
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

  defp show_manager_mod(), do: Application.get_env(:awards_voter, :show_manager_mod, ShowManager)
end