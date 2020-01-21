defmodule AwardsSite.Admin do
  @moduledoc """
  The Admin context.
  """
  
  alias AwardsSite.Show
  alias AwardsSite.Category
  alias AwardsVoter.Show, as: DbShow
  alias Ecto.Changeset

  @doc """
  Returns the list of shows.

  ## Examples

      iex> list_shows()
      [%Show{}, ...]

  """
  def list_shows do
    {:ok, all_shows} = AwardsVoter.Show.get_all_shows()
    all_shows
    |> AwardsVoter.Show.to_map()
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
    {:ok, show} = AwardsVoter.Show.get_show_by_name(name)
    show = AwardsVoter.Show.to_map(show) |> hd
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
      {:error, ...}

  """
  def create_show(attrs \\ %{}) do
    cs = Show.changeset(%Show{}, attrs)
    with true <- cs.valid?,
         %Show{} = site_show <- Changeset.apply_changes(cs),
         {:ok, show} <- AwardsVoter.Show.new(site_show.name, site_show.categories),
         {:ok, saved_show} <- AwardsVoter.Show.save_or_update_shows(show) do
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
  def update_show(%Show{} = show, attrs) do
    raise "TODO"
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
end
