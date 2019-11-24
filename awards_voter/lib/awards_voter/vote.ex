defmodule AwardsVoter.Vote do
  alias __MODULE__
  alias AwardsVoter.Category
  alias AwardsVoter.Contestant
  
  @enforce_keys [:category, :contestant]
  defstruct [:category, :contestant]
  @type t :: %__MODULE__{category: Category.t(), contestant: Contestant.t()}
  
  def new(category, contestant) do
    {:ok, %Vote{category: category, contestant: contestant}}
  end
end