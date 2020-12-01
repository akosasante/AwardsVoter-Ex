defmodule AwardsVoter.Context.Models.Category do
  @moduledoc """
    Schema for the category model and any methods for directly transforming/getting data from the model
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias AwardsVoter.Context.Models.Contestant
  alias Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  @type t :: %__MODULE__{
          name: String.t() | nil,
          description: String.t() | nil,
          contestants: list(Contestant.t()),
          winner: Contestant.t() | nil
        }
  @type change_result :: {:ok, Category.t()} | {:errors, Changeset.t()}

  embedded_schema do
    field :name, :string
    field :description, :string
    embeds_one :winner, Contestant, on_replace: :delete
    embeds_many :contestants, Contestant, on_replace: :delete
  end

  @spec changeset(Category.t(), map()) :: Ecto.Changeset.t()
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
    |> cast_embed(:winner)
    |> cast_embed(:contestants)
  end

  @spec to_changeset(Category.t()) :: Changeset.t()
  def to_changeset(%Category{} = category) do
    Category.changeset(category, %{})
  end

  @spec create(map()) :: change_result()
  def create(attrs \\ %{}) do
    cs = Category.changeset(%Category{}, attrs)

    if cs.valid? do
      {:ok, Changeset.apply_changes(cs)}
    else
      cs = %{cs | action: :create}
      {:errors, cs}
    end
  end

  @spec update(Category.t(), map()) :: change_result()
  def update(%Category{} = orig_category, attrs) do
    cs = Category.changeset(orig_category, attrs)

    if cs.valid? do
      {:ok, Changeset.apply_changes(cs)}
    else
      cs = %{cs | action: :update}
      {:errors, cs}
    end
  end

  def to_map(%Category{} = category) do
    contestants = category.contestants || []

    contestant_maps =
      Enum.map(contestants, fn
        %Contestant{} = contestant -> Map.from_struct(contestant)
        contestant -> contestant
      end)

    if Map.has_key?(category, :winner) and not is_nil(category.winner) do
      Map.put(category, :winner, Map.from_struct(category.winner))
    else
      category
    end
    |> Map.put(:contestants, contestant_maps)
    |> Map.from_struct()
  end
end
