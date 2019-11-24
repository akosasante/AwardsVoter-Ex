defmodule AwardsVoter.Category do
  alias __MODULE__
  
  @enforce_keys [:name]
  defstruct [:name, :contestants, :winner]
  @type t :: %__MODULE__{name: String.t(), contestants: list(), winner: String.t()}
  
  def new(name, contestants, winner) do
    {:ok, %Category{name: name, contestants: contestants, winner: winner}}
  end
end