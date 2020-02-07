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
    embeds_many :votes, Vote
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

  

  @spec vote(Ballot.t(), String.t(), String.t()) :: {:ok | :invalid_vote, Ballot.t()}
  def vote(ballot, category_name, contestant_name) do
    with {:get_category, %Vote{} = category_vote_entry} <- {:get_category, ballot.votes[category_name]},
         {:do_vote, {:ok, vote}} <- {:do_vote, Votes.vote(category_vote_entry, contestant_name)},
         {:update_ballot, {:ok, updated_ballot}} <- {:update_ballot, update_ballot_with_vote(ballot, vote)}
      do
      {:ok, updated_ballot}
    else
      {:get_category, nil} ->
        Logger.error("Category (#{category_name}) does not exist in ballot")
        {:invalid_vote, ballot}
      {:do_vote, _} ->
        Logger.error("Invalid or nil argument passed to Vote.vote/2")
        {:invalid_vote, ballot}
      {:update_ballot, e} ->
        Logger.error("Error raised when trying to update ballot: #{inspect e}")
        {:invalid_vote, ballot}
    end
  end

  @spec score(Ballot.t()) :: {:ok, non_neg_integer()}
  def score(ballot) do
    {:ok, Enum.count(ballot.votes, fn {_category_name, vote} -> Votes.is_winning_vote?(vote) end)}
  end
  
  @spec update_ballot_with_vote(Ballot.t(), Vote.t()) :: {:ok, Ballot.t()} | {:error, term()}
  defp update_ballot_with_vote(ballot, vote) do
    try do
      {:ok, %{ballot | votes: Map.update!(ballot.votes, vote.category.name, fn _ -> vote end)}}
    rescue
      e -> {:error, e}
    end
  end
end
