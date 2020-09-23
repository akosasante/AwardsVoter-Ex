defmodule AwardsVoter.Context.Models.Show do
  @moduledoc """
    Schema for the show model and any methods for directly transforming/getting data from the model
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias AwardsVoter.Context.Models.Category

  @primary_key {:id, :binary_id, autogenerate: true}

  @type t :: %__MODULE__{
          name: String.t() | nil,
          description: String.t() | nil,
          air_datetime: String.t() | nil,
          categories: list(Category.t())
        }

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
      :name,
      :description,
      :air_datetime
    ])
    |> validate_required([:name])
    |> cast_embed(:categories)
  end
end
