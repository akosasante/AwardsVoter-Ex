defmodule AwardsVoter.Context.Models.Vote do
  @moduledoc """
    Schema for the vote model and any methods for directly transforming/getting data from the model
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias AwardsVoter.Context.Models.Category
  alias AwardsVoter.Context.Models.Contestant
  alias Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  @type t :: %__MODULE__{
          category: Category.t() | nil,
          contestant: Contestant.t() | nil
        }
  @type change_result :: {:ok, Vote.t()} | {:errors, Changeset.t()}

  embedded_schema do
    embeds_one :category, Category, on_replace: :delete
    embeds_one :contestant, Contestant, on_replace: :delete
  end

  @spec changeset(Vote.t(), map()) :: Ecto.Changeset.t()
  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [])
    |> cast_embed(:category)
    |> cast_embed(:contestant)
    |> validate_required([:category])
  end

  @spec to_changeset(Vote.t()) :: Changeset.t()
  def to_changeset(%Vote{} = vote) do
    Vote.changeset(vote, %{})
  end

  @spec create(map()) :: change_result()
  def create(attrs \\ %{}) do
    cs = Vote.changeset(%Vote{}, attrs)

    if cs.valid? do
      {:ok, Changeset.apply_changes(cs)}
    else
      cs = %{cs | action: :create}
      {:errors, cs}
    end
  end

  @spec update(Vote.t(), map()) :: change_result()
  def update(%Vote{} = orig_vote, attrs) do
    cs = Vote.changeset(orig_vote, attrs)

    if cs.valid? do
      {:ok, Changeset.apply_changes(cs)}
    else
      cs = %{cs | action: :update}
      {:errors, cs}
    end
  end

  def is_winning_vote?(%Vote{category: category, contestant: contestant}) do
    !is_nil(category.winner) and category.winner.name == contestant.name
  end
end
