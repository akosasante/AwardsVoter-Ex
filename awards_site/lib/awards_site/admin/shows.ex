defmodule AwardsSite.Admin.Shows do
  @moduledoc """
  The Show context.
  """
  
  alias AwardsSite.Admin.Shows.Show
  alias AwardsSite.Admin.Categories.Category
  alias AwardsVoter.Show, as: DbShow
  alias Ecto.Changeset

  @doc """
  Returns the list of shows.

  ## Examples

      iex> list_shows()
      [%Show{}, ...]

  """
  def list_shows do
    {:ok, all_shows} = DbShow.get_all_shows()
    all_shows
    |> DbShow.to_maps()
    |> Enum.map(fn srvr_show -> 
      cs = Show.changeset(%Show{}, srvr_show)
      if cs.valid? do
        Changeset.apply_changes(cs)
      else
        cs
      end
    end)
  end

  @doc """
  Gets a single show.

  Raises if the Show does not exist.

  ## Examples

      iex> get_show!(123)
      %Show{}

  """
  def get_show!(name) do
    {:ok, show} = DbShow.get_show_by_name(name)
    show = DbShow.to_maps(show) |> hd
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
         {:ok, db_show} <- DbShow.new(site_show.name, site_show.categories),
         {:ok, _saved_show} <- DbShow.save_or_update_shows(db_show)
    do
      {:ok, site_show}
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
         {:ok, show} <- DbShow.new(site_show.name, site_show.categories),
         {:ok, saved_show} <- dets_show_update_helper(cs, show, orig_show)
    do
      {:ok, site_show}
    else
      _ -> cs = %{cs | action: :update}
           {:errors, cs}
    end
  end
  
#  def update_show_category(%Show{} = orig_show, updated_category_list) do
#
#  end
  
#  def save_show(%Show{} = show) do
#    
#  end

  @doc """
  Deletes a Show.

  ## Examples

      iex> delete_show(show)
      {:ok, %Show{}}

      iex> delete_show(show)
      {:error, ...}

  """
  def delete_show(%Show{} = show) do
    case DbShow.delete_show_entry(show.name) do
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
  
  defp dets_show_update_helper(%Changeset{} = cs, %DbShow{} = show, %Show{} = original) do
    case Changeset.get_change(cs, :name) do
      nil -> DbShow.save_or_update_shows(show)
      _updated_title -> case delete_show(original) do
                         {:ok, deleted_show} -> DbShow.save_or_update_shows(show)
                         e -> e
                       end
    end
  end
end
