defmodule AwardsVoter.Vote do
  alias __MODULE__
  alias AwardsVoter.Category
  alias AwardsVoter.Contestant
  
  @enforce_keys [:category]
  defstruct [:category, :contestant]
  @type t :: %__MODULE__{category: Category.t(), contestant: Contestant.t()}
  
  @spec new(Category.t(), Contestant.t()) :: {:ok, Vote.t()}
  def new(category, contestant \\ nil) do
    {:ok, %Vote{category: category, contestant: contestant}}
  end

  @spec is_winning_vote?(Vote.t()) :: boolean()
  def is_winning_vote?(%Vote{contestant: nil}), do: false
  
  @spec is_winning_vote?(Vote.t()) :: boolean()
  def is_winning_vote?(%Vote{category: nil}), do: false
    
  @spec is_winning_vote?(Vote.t()) :: boolean()
  def is_winning_vote?(%Vote{category: %Category{winner: nil}}), do: false
  
  @spec is_winning_vote?(Vote.t()) :: boolean()
  def is_winning_vote?(vote) do
    vote.contestant == vote.category.winner
  end
end