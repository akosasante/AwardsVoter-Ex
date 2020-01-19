defmodule AwardsSite.Contestant do
  use Ecto.Schema
  import Ecto.Changeset
  alias AwardsSite.Contestant

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
    IO.puts("in contestant changeset: #{inspect contestant}")

    #    types = %{
#      name: :string,
#      description: :string,
#      image_url: :string,
#      youtube_url: :string,
#      spotify_url: :string,
#      wiki_url: :string,
#      billboard_stats: :string,
#    }
    
    contestant
    |> cast(attrs, [:name, :description, :image_url, :youtube_url, :spotify_url, :wiki_url, :billboard_stats])
    |> IO.inspect
    |> validate_required([:name])
  end
end
