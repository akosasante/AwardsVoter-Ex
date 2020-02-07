defmodule AwardsVoter.Context.Voting.Votes.Vote do
  use Ecto.Schema
  import Ecto.Changeset
  
  alias __MODULE__
  alias Ecto.Changeset
  alias AwardsVoter.Context.Admin.Categories.Category
  alias AwardsVoter.Context.Admin.Contestants.Contestant
  
  @primary_key false
  @type t :: %__MODULE__{category: Category.t(), contestant: Contestant.t()}

  embedded_schema do
    embeds_one :category, Category
    embeds_one :contestant, Contestant
  end

  @spec new(Category.t(), Contestant.t() | nil) :: {:ok, Vote.t()}
  def new(category, contestant \\ nil) do
    {:ok, %Vote{category: category, contestant: contestant}}
  end # TODO: Make it so ballot.ex doesn't need this

  @spec changeset(Vote.t(), map()) :: Ecto.Changeset.t()
  def changeset(vote, attrs) do
    vote
    |> cast(attrs, []) #TODO: Confirm if we need to cast first before doing the embeds
    |> put_category()
    |> put_contestant()
    |> validate_required([:category])
  end
  
  defp put_category(%Changeset{params: %{"category" => category}} = cs) do
    put_embed(cs, :category, category)
  end
  defp put_category(cs), do: cs


  defp put_contestant(%Changeset{params: %{"contestant" => contestant}} = cs) do
    put_embed(cs, :contestant, contestant)
  end
  defp put_contestant(cs), do: cs
end