defmodule AwardsVoter.Context.Voting.Votes do
  alias AwardsVoter.Context.Voting.Votes.Vote
  alias Ecto.Changeset

  @type change_result :: {:ok, Vote.t()} | {:errors, Changeset.t()}
  
  @spec create_vote(map()) :: change_result
  def create_vote(attrs \\ %{}) do
    cs = Vote.changeset(%Vote{}, attrs)
    if cs.valid? do
      {:ok, Changeset.apply_changes(cs)}
    else
      cs = %{cs | action: :create}
      {:errors, cs}
    end
  end
end