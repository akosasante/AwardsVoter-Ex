defmodule AwardsVoter.Vote do
  alias __MODULE__
  
  @enforce_keys [:category, :contestant]
  defstruct [:category, :contestant]
  @type t :: %__MODULE__{category: String.t(), contestant: String.t()}
  
  def new(category, contestant) do
    {:ok, %Vote{category: category, contestant: contestant}}
  end
end