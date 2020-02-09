defmodule AwardsVoter.Context.Admin.Contestants do
  @moduledoc """
  The Contestant context.
  """
  
  alias AwardsVoter.Context.Admin.Contestants.Contestant
  alias Ecto.Changeset
  
  @type change_result :: {:ok, Contestant.t()} | {:errors, Changeset.t()}

  @spec create_contestant(map()) :: change_result()
  def create_contestant(attrs \\ %{}) do
    cs = Contestant.changeset(%Contestant{}, attrs)
    if cs.valid? do
      {:ok, Changeset.apply_changes(cs)}
    else
      cs = %{cs | action: :create}
      {:errors, cs}
    end
  end
  
  @spec update_contestant(Contestant.t(), map()) :: change_result()
  def update_contestant(%Contestant{} = orig_contestant, attrs) do
    cs = Contestant.changeset(orig_contestant, attrs)
    if cs.valid? do
      {:ok, Changeset.apply_changes(cs)}
    else
      cs = %{cs | action: :update}
      {:errors, cs}
    end
  end

  @spec change_contestant(Contestant.t()) :: Changeset.t()
  def change_contestant(%Contestant{} = contestant) do
    Contestant.changeset(contestant, %{})
  end
end