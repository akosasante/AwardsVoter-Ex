defmodule AwardsVoter.Context.Models.Category do
  @moduledoc """
    Schema for the category model and any methods for directly transforming/getting data from the model
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias AwardsVoter.Context.Models.Contestant

  @primary_key {:id, :binary_id, autogenerate: true}

  @type t :: %__MODULE__{
          name: String.t() | nil,
          description: String.t() | nil,
          contestants: list(Contestant.t()),
          winner: Contestant.t() | nil
        }

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
end
