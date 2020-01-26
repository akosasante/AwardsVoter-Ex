defmodule AwardsVoter.Context.Admin.Shows do
  @moduledoc """
  The Show context.
  """

  alias AwardsVoter.Context.Admin.Shows.Show
#  alias AwardsVoter.Context.Admin.Categories.Category
  alias Ecto.Changeset

  @doc """
  Returns the list of shows.

  ## Examples

      iex> list_shows()
      [%Show{}, ...]

  """
  def list_shows, do: Show.get_all_shows()

  @doc """
  Gets a single show.

  Raises if the Show does not exist.

  ## Examples

      iex> get_show_by_name("Oscars")
      %Show{}

  """
  def get_show_by_name(name) do
    {:ok, show} = Show.get_show_by_name(name)
#    show = DbShow.to_maps(show) |> hd
    cs = Show.changeset(%Show{}, show)
    if cs.valid? do
      Changeset.apply_changes(cs)
    else
      cs
    end
  end

  @doc """
  Creates a show.

  ## Examples

      iex> create_show(%{field: value})
      {:ok, %Show{}}

      iex> create_show(%{field: bad_value})
      {:errors, ...}

  """
  def create_show(attrs \\ %{}) do
    cs = Show.changeset(%Show{}, attrs)
    with true <- cs.valid?,
         %Show{} = site_show <- Changeset.apply_changes(cs),
#         {:ok, db_show} <- DbShow.new(site_show.name, site_show.categories),
         {:ok, saved_show} <- Show.save_or_update_shows(site_show)
      do
      {:ok, saved_show}
    else
      _ -> cs = %{cs | action: :create}
           {:errors, cs}
    end
  end

  @doc """
  Updates a show.

  ## Examples

      iex> update_show(show, %{field: new_value})
      {:ok, %Show{}}

      iex> update_show(show, %{field: bad_value})
      {:error, ...}

  """
  def update_show(%Show{} = orig_show, attrs) do
    cs = Show.changeset(orig_show, attrs)
    with true <- cs.valid?,
         %Show{} = site_show <- Changeset.apply_changes(cs),
         {:ok, saved_show} <- dets_show_update_helper(cs, site_show, orig_show)
      do
      {:ok, saved_show}
    else
      _ -> cs = %{cs | action: :update}
           {:errors, cs}
    end
  end

  @doc """
  Deletes a Show.

  ## Examples

      iex> delete_show(show)
      {:ok, %Show{}}

      iex> delete_show(show)
      {:error, ...}

  """
  def delete_show(%Show{} = show) do
    case Show.delete_show_entry(show.name) do
      :ok -> {:ok, show}
      e -> {:error, e}
    end
  end

  @doc """
  Returns a data structure for tracking show changes.

  ## Examples

      iex> change_show(show)
      %Show{...}

  """
  def change_show(%Show{} = show) do
    Show.changeset(show, %{})
  end

  defp dets_show_update_helper(%Changeset{} = cs, %Show{} = show, %Show{} = original) do
    case Changeset.get_change(cs, :name) do
      nil -> Show.save_or_update_shows(show)
      _updated_title -> case delete_show(original) do
                          {:ok, _deleted_show} -> Show.save_or_update_shows(show)
                          e -> e
                        end
    end
  end
end