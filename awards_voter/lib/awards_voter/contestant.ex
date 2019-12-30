defmodule AwardsVoter.Contestant do
  alias __MODULE__

  @enforce_keys [:name]
  defstruct [:name, :description, :image_url, :youtube_url, :wiki_url, :billboard_stats]

  @type t :: %__MODULE__{
          name: String.t(),
          description: String.t(),
          image_url: String.t(),
          youtube_url: String.t(),
          spotify_url: String.t(),
          wiki_url: String.t(),
          billboard_stats: String.t()
        }

  @spec new(String.t(), String.t()) :: {:ok, Contestant.t()}
  def new(name, description \\ nil) do
    {:ok, %Contestant{name: name, description: description}}
  end

  @spec set_image_url(Contestant.t(), String.t()) :: Contestant.t()
  def set_image_url(%Contestant{} = contestant, image_url) do
    {:ok, %{contestant | image_url: image_url}}
  end

  @spec set_youtube_url(Contestant.t(), String.t()) :: Contestant.t()
  def set_youtube_url(%Contestant{} = contestant, youtube_url) do
    {:ok, %{contestant | youtube_url: youtube_url}}
  end

  @spec set_wiki_url(Contestant.t(), String.t()) :: Contestant.t()
  def set_wiki_url(%Contestant{} = contestant, wiki_url) do
    {:ok, %{contestant | wiki_url: wiki_url}}
  end

  @spec set_spotify_url(Contestant.t(), String.t()) :: Contestant.t()
  def set_spotify_url(%Contestant{} = contestant, spotify_url) do
    {:ok, %{contestant | spotify_url: spotify_url}}
  end

  @spec set_billboard_stats(Contestant.t(), String.t()) :: Contestant.t()
  def set_billboard_stats(%Contestant{} = contestant, billboard_stats) do
    {:ok, %{contestant | billboard_stats: billboard_stats}}
  end
end
