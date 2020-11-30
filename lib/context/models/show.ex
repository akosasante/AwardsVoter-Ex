defmodule AwardsVoter.Context.Models.Show do
  @moduledoc """
    Schema for the show model and any methods for directly transforming/getting data from the model
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias AwardsVoter.Context.Models.Category
  alias Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t() | nil,
          description: String.t() | nil,
          air_datetime: String.t() | nil,
          categories: list(Category.t())
        }
  @type change_result :: {:ok, Show.t()} | {:errors, Changeset.t()}

  embedded_schema do
    field :name, :string
    field :description, :string
    field :air_datetime, :string
    embeds_many :categories, Category, on_replace: :delete
  end

  @spec changeset(Show.t(), map()) :: Ecto.Changeset.t()
  def changeset(show, attrs) do
    show
    |> cast(attrs, [
      :id,
      :name,
      :description,
      :air_datetime
    ])
    |> validate_required([:name])
    |> cast_embed(:categories)
  end

  @spec to_changeset(Show.t()) :: Changeset.t()
  def to_changeset(%Show{} = show) do
    Show.changeset(show, %{})
  end

  @spec create(map()) :: change_result()
  def create(attrs \\ %{}) do
    cs = Show.changeset(%Show{}, attrs)

    if cs.valid? do
      {:ok, Changeset.apply_changes(cs)}
    else
      cs = %{cs | action: :create}
      {:errors, cs}
    end
  end

  @spec update(Show.t(), map()) :: change_result()
  def update(%Show{} = orig_show, attrs) do
    cs = Show.changeset(orig_show, attrs)

    if cs.valid? do
      {:ok, Changeset.apply_changes(cs)}
    else
      cs = %{cs | action: :update}
      {:errors, cs}
    end
  end

  def add_id(%Show{id: id} = show) when is_nil(id) do
    %Show{show | id: Ecto.UUID.generate() }
  end

  def add_id(%Show{} = show) do
    show
  end

  def to_map(%Show{} = show) do
    if Enum.empty?(show.categories) do
      Map.from_struct(show)
    else
      category_maps = Enum.map(show.categories, &Category.to_map/1)

      show
      |> Map.put(:categories, category_maps)
      |> Map.from_struct()
    end
  end
end
