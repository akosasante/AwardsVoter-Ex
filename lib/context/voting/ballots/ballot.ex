defmodule AwardsVoter.Context.Voting.Ballots.Ballot do
  use Ecto.Schema
  import Ecto.Changeset
  
  alias __MODULE__
  alias Ecto.Changeset
  alias AwardsVoter.Context.Voting.Votes.Vote
  alias AwardsVoter.Context.Voting.Votes.Voter

  require Logger
  
  @primary_key false

  @type t :: %__MODULE__{voter: String.t() | nil, votes: list(Vote.t())}
  
  embedded_schema do
    field :voter, :string
    embeds_many :votes, Vote, on_replace: :delete
  end
  
  @spec changeset(Ballot.t(), map()) :: Ecto.Changeset.t()
  def changeset(ballot, attrs) do
    ballot
    |> cast(attrs, [:voter])
    |> put_votes()
    |> validate_required([:voter])
  end
  
  def save_ballot(ballot, show_name, voter_mod \\ Voter) do
    case voter_mod.save_ballot(ballot, show_name) do
      :ok -> {:ok, ballot}
      {:error, e} ->
        Logger.error("Due to #{inspect e} failed to save ballot #{inspect ballot}")
        :error_saving
    end
  end
  
  def get_ballot_by_voter_and_show(voter_name, show_name, voter_mod \\ Voter) do
    case voter_mod.get_ballot_by_voter_and_show(voter_name, show_name) do
      :not_found -> :not_found
      {:error, reason} ->
        Logger.error("Due to #{inspect reason} failed to lookup ballot for #{inspect voter_name} and #{inspect show_name}")
        :error_finding
      ballot -> {:ok, ballot}
    end
  end
  
  defp put_votes(%Changeset{params: %{"votes" => votes}} = cs) do
    put_embed(cs, :votes, votes)
  end
  defp put_votes(cs), do: cs
end
