defmodule AwardsSite.Show do
  use Ecto.Schema
  import Ecto.Changeset
  alias AwardsSite.Show
  alias AwardsSite.Category

  @derive {Phoenix.Param, key: :name}
  
  embedded_schema do
    field :name, :string
    embeds_many :categories, AwardsVoter.Category
  end

  @doc false
  def changeset(%Show{} = show, attrs) do
    show
    |> cast(attrs, [:name])
#    |> cast_embed(:categories)
    |> validate_required([:name])
  end
end
