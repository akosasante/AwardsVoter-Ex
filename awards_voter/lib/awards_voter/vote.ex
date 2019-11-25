defmodule AwardsVoter.Vote do
  alias __MODULE__
  alias AwardsVoter.Category
  alias AwardsVoter.Contestant
  
  @enforce_keys [:category]
  defstruct [:category, :contestant]
  @type t :: %__MODULE__{category: Category.t(), contestant: Contestant.t()}
  
  def new(category, contestant \\ nil) do
    {:ok, %Vote{category: category, contestant: contestant}}
  end
end