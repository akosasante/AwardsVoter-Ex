defmodule AwardsVoter.Context.Admin.Contestants.Contestant do
  use Ecto.Schema
  import Ecto.Changeset
  
  alias __MODULE__

  @primary_key false

  @type t :: %__MODULE__{
               name: String.t(),
               description: String.t() | nil,
               image_url: String.t() | nil,
               youtube_url: String.t() | nil,
               spotify_url: String.t() | nil,
               wiki_url: String.t() | nil,
               billboard_stats: String.t() | nil
             }

  embedded_schema do
    field :name, :string
    field :description, :string
    field :image_url, :string
    field :youtube_url, :string
    field :spotify_url, :string
    field :wiki_url, :string
    field :billboard_stats, :string
  end

  @spec changeset(Contestant.t(), map()) :: Ecto.Changeset.t()
  def changeset(contestant, attrs) do
    contestant
    |> cast(attrs, [:name, :description, :image_url, :youtube_url, :spotify_url, :wiki_url, :billboard_stats])
    |> validate_required([:name])
  end
end