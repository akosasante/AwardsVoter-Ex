defmodule AwardsVoter.Category do
  alias __MODULE__
  alias AwardsVoter.Contestant

  @enforce_keys [:name]
  defstruct [:name, :contestants, :winner]

  @type t :: %__MODULE__{
          name: String.t(),
          contestants: nonempty_list(Contestant.t()),
          winner: Contestant.t()
        }

  def new(name, contestants \\ [], winner \\ nil) do
    {:ok, %Category{name: name, contestants: contestants, winner: winner}}
  end
end
