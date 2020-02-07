defmodule AwardsVoter.Context.Admin.Categories.Category do
  use Ecto.Schema
  import Ecto.Changeset
  
  alias __MODULE__
  alias AwardsVoter.Context.Admin.Contestants.Contestant

  @primary_key false

  @type t :: %__MODULE__{
               name: String.t() | nil,
               contestants: list(Contestant.t()),
               winner: Contestant.t() | nil,
               description: String.t() | nil
             }

  embedded_schema do
    field :description, :string
    field :name, :string
    embeds_one :winner, Contestant
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