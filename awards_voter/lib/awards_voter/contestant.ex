defmodule AwardsVoter.Contestant do
  alias __MODULE__

  @enforce_keys [:name]
  defstruct [:name, :description, :image_url, :youtube_url, :wiki_url, :billboard_stats, :spotify_url]

  @type t :: %__MODULE__{
          name: String.t(),
          description: String.t() | nil,
          image_url: String.t() | nil,
          youtube_url: String.t() | nil,
          spotify_url: String.t() | nil,
          wiki_url: String.t() | nil,
          billboard_stats: String.t() | nil
        }

  @spec new(String.t(), String.t() | nil) :: {:ok, Contestant.t()}
  def new(name, description \\ nil) do
    {:ok, %Contestant{name: name, description: description}}
  end

  @spec set_image_url(Contestant.t(), String.t()) :: {:ok, %Contestant{image_url: String.t()}}
  def set_image_url(%Contestant{} = contestant, image_url) do
    {:ok, %{contestant | image_url: image_url}}
  end

  @spec set_youtube_url(Contestant.t(), String.t()) :: {:ok, %Contestant{youtube_url: String.t()}}
  def set_youtube_url(%Contestant{} = contestant, youtube_url) do
    {:ok, %{contestant | youtube_url: youtube_url}}
  end

  @spec set_wiki_url(Contestant.t(), String.t()) :: {:ok, %Contestant{wiki_url: String.t()}}
  def set_wiki_url(%Contestant{} = contestant, wiki_url) do
    {:ok, %{contestant | wiki_url: wiki_url}}
  end

  @spec set_spotify_url(Contestant.t(), String.t()) :: {:ok, %Contestant{spotify_url: String.t()}}
  def set_spotify_url(%Contestant{} = contestant, spotify_url) do
    {:ok, %{contestant | spotify_url: spotify_url}}
  end

  @spec set_billboard_stats(Contestant.t(), String.t()) :: {:ok, %Contestant{billboard_stats: String.t()}}
  def set_billboard_stats(%Contestant{} = contestant, billboard_stats) do
    {:ok, %{contestant | billboard_stats: billboard_stats}}
  end
  
  def to_map(contestants) when is_list(contestants) do
    contestants
    |> Enum.reject(fn contestant -> is_nil(contestant) end)
    |> Enum.map(fn contestant -> %{
      name: contestant.name,
      description: contestant.description,
      image_url: contestant.image_url,
      youtube_url: contestant.youtube_url,
      wiki_url: contestant.wiki_url,
      spotify_url: contestant.spotify_url,
      billboard_stats: contestant.billboard_stats} 
    end)
  end
  def to_map(contestant), do: to_map([contestant])
end
