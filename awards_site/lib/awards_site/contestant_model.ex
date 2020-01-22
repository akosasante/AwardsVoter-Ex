defmodule AwardsSite.ContestantModel do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

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
  def changeset(contestant, attrs) do
    contestant
    |> cast(attrs, [:name, :description, :image_url, :youtube_url, :spotify_url, :wiki_url, :billboard_stats])
    |> validate_required([:name])
  end
end
