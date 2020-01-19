defmodule AwardsSite.Show do
  use Ecto.Schema
  import Ecto.Changeset
  alias AwardsSite.Show
  alias AwardsSite.Category

  @derive {Phoenix.Param, key: :name}
  @primary_key false

  embedded_schema do
    field :name, :string
    embeds_many :categories, Category
  end

  @doc false
  def changeset(show, attrs) do
    IO.puts("in show changeset: #{inspect attrs}")

    #    types = %{
#      name: :string,
#      categories: {:array, Category}
#    } 
        
    show
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> IO.inspect
    |> cast_embed(:categories)
  end
end
