defmodule AwardsVoter.Context.Models.Vote do
  @moduledoc """
    Schema for the vote model and any methods for directly transforming/getting data from the model
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias AwardsVoter.Context.Models.Category
  alias AwardsVoter.Context.Models.Contestant

  @primary_key {:id, :binary_id, autogenerate: true}

  @type t :: %__MODULE__{
          category: Category.t() | nil,
          contestant: Contestant.t() | nil
        }

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
end
