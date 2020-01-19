defmodule AwardsSite.Category do
  use Ecto.Schema
  import Ecto.Changeset
  alias AwardsSite.{Category, Contestant}

  @primary_key false

  embedded_schema do
    field :description, :string
    field :name, :string
    embeds_one :winner, Contestant
    embeds_many :contestants, Contestant
  end

  @doc false
  def changeset(category, attrs) do
    IO.puts("in category changeset: #{inspect attrs}")
#    types = %{
#      name: :string,
#      description: :string,
#      winner: Contestant,
#      contestants: Contestant
#    }
#    
    
    category
    |> cast(attrs, [:name, :description])
    |> IO.inspect
#    |> cast_embed(:contestants)
#    |> cast_embed(:winner)
    |> validate_required([:name])
  end
end
