defmodule AwardsVoter.Context.Models.Ballot do
  @moduledoc """
    Schema for the ballot model and any methods for directly transforming/getting data from the model
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias AwardsVoter.Context.Models.Vote
  alias Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  @type t :: %__MODULE__{
          id: String.t() | nil,
          voter: String.t() | nil,
          show_id: String.t() | nil,
          votes: list(Vote.t())
        }
  @type change_result :: {:ok, Ballot.t()} | {:errors, Changeset.t()}

  embedded_schema do
    field :voter, :string
    field :show_id, :string
    embeds_many :votes, Vote, on_replace: :delete
  end

  @spec changeset(Ballot.t(), map()) :: Ecto.Changeset.t()
  def changeset(ballot, attrs) do
    ballot
    |> cast(attrs, [:voter, :show_id])
    |> validate_required([:voter, :show_id])
    |> cast_embed(:votes)
  end

  @spec to_changeset(Ballot.t()) :: Changeset.t()
  def to_changeset(%Ballot{} = ballot \\ %Ballot{}) do
    Ballot.changeset(ballot, %{})
  end

  @spec create(map()) :: change_result()
  def create(attrs \\ %{}) do
    cs = Ballot.changeset(%Ballot{}, attrs)

    if cs.valid? do
      {:ok, Changeset.apply_changes(cs)}
    else
      cs = %{cs | action: :create}
      {:errors, cs}
    end
  end

  def add_id(%Ballot{id: id} = ballot) when is_nil(id) do
    %Ballot{ballot | id: Ecto.UUID.generate()}
  end

  @spec update(Ballot.t(), map()) :: change_result()
  def update(%Ballot{} = orig_ballot, attrs) do
    cs = Ballot.changeset(orig_ballot, attrs)

    if cs.valid? do
      {:ok, Changeset.apply_changes(cs)}
    else
      cs = %{cs | action: :update}
      {:errors, cs}
    end
  end
end
