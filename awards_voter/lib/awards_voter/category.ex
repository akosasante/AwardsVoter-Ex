defmodule AwardsVoter.Category do
  alias __MODULE__
  alias AwardsVoter.Contestant

  @enforce_keys [:name]
  defstruct [:name, :contestants, :winner, :description]

  @type t :: %__MODULE__{
          name: String.t(),
          contestants: nonempty_list(Contestant.t()),
          winner: Contestant.t(),
          description: String.t()
        }

  @spec new(String.t(), list(Contestant.t()), Contestant.t()) :: {:ok, Category.t()}
  def new(name, contestants \\ [], winner \\ nil, description \\ nil) do
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
end
