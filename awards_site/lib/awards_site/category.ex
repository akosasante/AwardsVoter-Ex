defmodule AwardsSite.Category do
  use Ecto.Schema
  import Ecto.Changeset
  alias AwardsSite.{Category, Contestant}

  embedded_schema do
    field :description, :string
    field :name, :string
    embeds_one :winner, Contestant
    embeds_many :contestants, Contestant
  end

  @doc false
  def changeset(%Category{} = category, attrs) do
    category
    |> cast(attrs, [:name, :description])
#    |> cast_embed([:contestants, :winner])
    |> validate_required([:name])
  end
end
