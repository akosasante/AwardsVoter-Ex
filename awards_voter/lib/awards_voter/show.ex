defmodule AwardsVoter.Show do
  alias __MODULE__
  alias AwardsVoter.Category
  
  @enforce_keys [:name]
  defstruct [:name, :categories]
  @type t :: %__MODULE__{name: String.t(), categories: nonempty_list(%Category{})}
  
  def new(name, categories \\ []) do
    {:ok, %Show{name: name, categories: categories}}
  end
end