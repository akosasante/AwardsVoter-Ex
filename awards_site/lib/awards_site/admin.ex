defmodule AwardsSite.Admin do
  @moduledoc """
  The Admin context.
  """
  
  alias AwardsSite.Show
  alias AwardsSite.Category
  alias Ecto.Changeset

  @doc """
  Returns the list of shows.

  ## Examples

      iex> list_shows()
      [%Show{}, ...]

  """
  def list_shows do
    [
      %Show{id: 1, name: "2019 Grammy Awards", categories: [
                                                 %Category{
                                                   contestants: [],
                                                   name: "Album of the Year",
                                                   winner: nil
                                                 },
                                                 %Category{
                                                   contestants: [],
                                                   name: "Record of the Year",
                                                   winner: nil
                                                 },
                                                 %Category{
                                                   contestants: [],
                                                   name: "Artist of the Year",
                                                   winner: nil
                                                 },
                                                 %Category{
                                                   contestants: [],
                                                   name: "Songwriter of the Year",
                                                   winner: nil
                                                 }
      ]},
      %Show{id: 2, name: "2019 Screen Actors Guild Awards", categories: []},
      %Show{id: 3, name: "2019 Academy Awards", categories: []}
    ]
  end

  @doc """
  Gets a single show.

  Raises if the Show does not exist.

  ## Examples

      iex> get_show!(123)
      %Show{}

  """
  def get_show!(id) do
    id = String.to_integer(id)
    Enum.find(list_shows(), fn show -> show.id == id end)
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
    if cs.valid? do
      show = Changeset.apply_changes(cs) |> Map.put(:id, 2)
      {:ok, show}
    else
      cs = %{cs | action: :create}
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
    raise "TODO"
  end

  @doc """
  Returns a data structure for tracking show changes.

  ## Examples

      iex> change_show(show)
      %Todo{...}

  """
  def change_show(%Show{} = show) do
    Show.changeset(show, %{})
  end
end
