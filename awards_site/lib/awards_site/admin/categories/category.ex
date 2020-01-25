defmodule AwardsSite.Admin.Categories.Category do
  use Ecto.Schema
  import Ecto.Changeset
  alias AwardsSite.Admin.Contestants.Contestant

  @primary_key false

  embedded_schema do
    field :description, :string
    field :name, :string
    embeds_one :winner, Contestant
    embeds_many :contestants, Contestant, on_replace: :delete
  end

  @doc false
  def changeset(category, attrs) do
    IO.inspect(category)
    category
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
    |> IO.inspect
    |> cast_embed(:winner)
    |> cast_embed(:contestants)
    |> IO.inspect
  end
end
