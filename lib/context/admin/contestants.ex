defmodule AwardsVoter.Context.Admin.Contestants do
  @moduledoc """
  The Contestant context.
  """
  
  alias AwardsVoter.Context.Admin.Contestants.Contestant
  alias Ecto.Changeset

  def create_contestant(attrs \\ %{}) do
    cs = Contestant.changeset(%Contestant{}, attrs)
    if cs.valid? do
      {:ok, Changeset.apply_changes(cs)}
    else
      cs = %{cs | action: :create}
      {:errors, cs}
    end
  end

  def change_category(%Contestant{} = contestant) do
    Contestant.changeset(contestant, %{})
  end
end