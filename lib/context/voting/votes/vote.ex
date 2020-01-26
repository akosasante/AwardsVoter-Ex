defmodule AwardsVoter.Context.Voting.Votes.Vote do
  use Ecto.Schema
  import Ecto.Changeset
  
  alias __MODULE__
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
    |> validate_required([:category, :contestant])
    |> cast_embed(:category)
    |> cast_embed(:contestant)
  end
end