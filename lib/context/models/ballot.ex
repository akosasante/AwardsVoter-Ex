defmodule AwardsVoter.Context.Models.Ballot do
  @moduledoc """
    Schema for the ballot model and any methods for directly transforming/getting data from the model
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias AwardsVoter.Context.Models.Vote

  @primary_key {:id, :binary_id, autogenerate: true}

  @type t :: %__MODULE__{
          voter: String.t() | nil,
          votes: list(Vote.t())
        }

  embedded_schema do
    embeds_one :voter, :string
    embeds_many :votes, Vote, on_replace: :delete
  end

  @spec changeset(Ballot.t(), map()) :: Ecto.Changeset.t()
  def changeset(ballot, attrs) do
    ballot
    |> cast(attrs, [:voter])
    |> validate_required([:voter])
    |> cast_embed(:votes)
  end
end
