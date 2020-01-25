defmodule AwardsSite.Admin.Shows.Show do
  use Ecto.Schema
  import Ecto.Changeset
  alias AwardsSite.Admin.Categories.Category

  @derive {Phoenix.Param, key: :name}
  @primary_key false

  embedded_schema do
    field :name, :string
    embeds_many :categories, Category, on_replace: :delete
  end

  @doc false
  def changeset(show, attrs) do
    show
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> cast_embed(:categories)
  end
  
#  def update_categories_changes
end
