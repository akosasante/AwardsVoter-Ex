defmodule AwardsVoter.Context.Ballots do
  @moduledoc """
  Entrypoint for methods to manage voter ballots
  """

  alias AwardsVoter.Context.Models.Vote
  alias AwardsVoter.Context.Models.Ballot
  alias AwardsVoter.Context.Tables.BallotTable

  defdelegate vote_changeset(vote), to: Vote, as: :to_changeset
  defdelegate ballot_changeset(ballot), to: Ballot, as: :to_changeset

  def create_vote(vote_attrs) do
    {:ok, vote} = Vote.create(vote_attrs)
    vote
  end

  def new_ballot(), do: Ballot.to_changeset()

  def get_ballot(id) do
    BallotTable.get_by_id(id)
  end

  def create_ballot(ballot_map) do
    with {:ok, ballot} <- Ballot.create(ballot_map),
         ballot <- Ballot.add_id(ballot),
         :ok <- BallotTable.save([{ballot.id, ballot}])
      do
      ballot
    end
  end

  def save_ballot(%Ballot{} = existing_ballot) do
    BallotTable.save([{existing_ballot.id, existing_ballot}])
  end

  def find_ballot_by_voter_and_show(voter_name, show_id) do
    case BallotTable.get_by_voter_and_show(voter_name, show_id) do
      %Ballot{} = ballot -> ballot
      _ -> nil
    end
  end
end
