defmodule AwardsVoter.Context.Voting.Ballots.Ballot do
  use Ecto.Schema
  import Ecto.Changeset
  
  alias __MODULE__
  alias Ecto.Changeset
  alias AwardsVoter.Context.Admin.Shows.Show
  alias AwardsVoter.Context.Admin.Categories.Category
  alias AwardsVoter.Context.Voting.Votes.Vote
  alias AwardsVoter.Context.Voting.Votes

  require Logger
  
  @primary_key false

  @type votemap :: %{required(String.t()) => Vote.t()}
  @type t :: %__MODULE__{voter: String.t(), votes: votemap | nil}
  
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
  
  defp put_votes(%Changeset{params: %{"votes" => votes}} = cs) do
    put_embed(cs, :votes, votes)
  end
  defp put_votes(cs), do: cs
end
