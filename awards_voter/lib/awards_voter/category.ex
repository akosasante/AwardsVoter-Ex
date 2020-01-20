defmodule AwardsVoter.Category do
  alias __MODULE__
  alias AwardsVoter.Contestant

  @enforce_keys [:name]
  defstruct name: nil, contestants: [], description: nil, winner: nil

  @type t :: %__MODULE__{
          name: String.t(),
          contestants: nonempty_list(Contestant.t()),
          winner: Contestant.t(),
          description: String.t()
        }

  @spec new(String.t(), list(Contestant.t() | map()), String.t() | nil, Contestant.t() | nil) :: {:ok, Category.t()}
  def new(name, contestants \\ [], description \\ nil, winner \\ nil) do
    struct_contestants = Enum.map(contestants, fn
      %Contestant{} = contestant -> contestant
      contestant_map ->
        {:ok, contestant} = Contestant.new(Map.get(contestant_map, :name), Map.get(contestant_map, :description))
        {:ok, contestant} = Contestant.set_image_url(contestant, Map.get(contestant_map, :image_url))
        {:ok, contestant} = Contestant.set_youtube_url(contestant, Map.get(contestant_map, :youtube_url))
        {:ok, contestant} = Contestant.set_wiki_url(contestant, Map.get(contestant_map, :wiki_url))
        {:ok, contestant} = Contestant.set_billboard_stats(contestant, Map.get(contestant_map, :billboard_stats))
        contestant
    end)
    {:ok, %Category{name: name, contestants: struct_contestants, winner: winner, description: description}}
  end
  
  def to_map(categories) when is_list(categories) do
    categories
    |> Enum.reject(fn category -> is_nil(category) end)
    |> Enum.map(fn category -> %{
      name: category.name, 
      description: category.description, 
      winner: Contestant.to_map(category.winner),
      contestants: Contestant.to_map(category.contestants)} 
    end)
  end
  def to_map(nil), do: nil
  def to_map(%Category{} = category), do: to_map([category])
end
