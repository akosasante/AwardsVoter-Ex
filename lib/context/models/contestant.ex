defmodule AwardsVoter.Context.Models.Contestant do
  @moduledoc """
    Schema for the contestant model and any methods for directly transforming/getting data from the model
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  @type change_result :: {:ok, Contestant.t()} | {:errors, Changeset.t()}
  @type t :: %__MODULE__{
          name: String.t() | nil,
          description: String.t() | nil,
          image_url: String.t() | nil,
          youtube_url: String.t() | nil,
          spotify_url: String.t() | nil,
          wiki_url: String.t() | nil,
          billboard_stats: String.t() | nil
        }

  embedded_schema do
    field :name, :string
    field :description, :string
    field :image_url, :string
    field :youtube_url, :string
    field :spotify_url, :string
    field :wiki_url, :string
    field :billboard_stats, :string
  end

  @spec changeset(Contestant.t(), map()) :: Ecto.Changeset.t()
  def changeset(contestant, attrs) do
    contestant
    |> cast(attrs, [
      :name,
      :description,
      :image_url,
      :youtube_url,
      :spotify_url,
      :wiki_url,
      :billboard_stats
    ])
    |> validate_required([:name])
  end

  @spec to_changeset(Contestant.t()) :: Changeset.t()
  def to_changeset(%Contestant{} = contestant) do
    Contestant.changeset(contestant, %{})
  end

  @spec create(map()) :: change_result()
  def create(attrs \\ %{}) do
    cs = Contestant.changeset(%Contestant{}, attrs)

    if cs.valid? do
      {:ok, Changeset.apply_changes(cs)}
    else
      cs = %{cs | action: :create}
      {:errors, cs}
    end
  end

  @spec update(Contestant.t(), map()) :: change_result()
  def update(%Contestant{} = orig_contestant, attrs) do
    cs = Contestant.changeset(orig_contestant, attrs)

    if cs.valid? do
      {:ok, Changeset.apply_changes(cs)}
    else
      cs = %{cs | action: :update}
      {:errors, cs}
    end
  end
end
