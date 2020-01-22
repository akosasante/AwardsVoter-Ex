defmodule AwardsSite.CategoryModel do
  use Ecto.Schema
  import Ecto.Changeset
  alias AwardsSite.ContestantModel

  @primary_key false

  embedded_schema do
    field :description, :string
    field :name, :string
    embeds_one :winner, ContestantModel
    embeds_many :contestants, ContestantModel
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
    |> cast_embed(:contestants)
    |> cast_embed(:winner)
  end
end
