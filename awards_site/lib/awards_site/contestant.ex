defmodule AwardsSite.Contestant do
  use Ecto.Schema
  import Ecto.Changeset
  alias AwardsSite.Contestant

  embedded_schema do
    field :name, :string
    field :description, :string
    field :image_url, :string
    field :youtube_url, :string
    field :spotify_url, :string
    field :wiki_url, :string
    field :billboard_stats, :string
  end

  @doc false
  def changeset(%Contestant{} = Contestant, attrs) do
    Contestant
    |> cast(attrs, [:name, :description, :image_url, :youtube_url, :spotify_url, :wiki_url, :billboard_stats])
    |> validate_required([:name])
  end
end
