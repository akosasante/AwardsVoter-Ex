defmodule AwardsSite.Show do
  use Ecto.Schema
  import Ecto.Changeset
  alias AwardsSite.Show
  alias AwardsSite.Category

  embedded_schema do
    field :name, :string
    embeds_many :categories, Category
  end

  @doc false
  def changeset(%Show{} = show, attrs) do
    show
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
