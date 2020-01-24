defmodule AwardsSite.Admin.Categoriess do
  @moduledoc """
  The Category context.
  """
  
  alias AwardsSite.Admin.Categories.Category
  alias AwardsSite.Admin.Shows.Show
  alias AwardsVoter.Category, as: DbCategory
  alias Ecto.Changeset

  @doc """
  Returns the list of categories for a particular show.

  ## Examples

      iex> list_categories_for_show(show)
      [%Category{}, ...]

  """
  def list_categories_for_show(%Show{} = show) do
#    {:ok, all_categories} = DbCategory.get_all_categories()
#    all_categories
#    |> DbCategory.to_maps()
#    |> Enum.map(fn db_category -> 
#      cs = Category.changeset(%Category{}, db_category)
#      if cs.valid? do
#        Changeset.apply_changes(cs)
#      else
#        cs
#      end
#    end)
  end

  @doc """
  Gets a single category.

  Raises if the Category does not exist.

  ## Examples

      iex> get_show_category(show, category_name)
      %Category{}

  """
  def get_show_category(%Show{} = show, name) do
#    {:ok, category} = DbCategory.get_category_by_name(name)
#    category = DbCategory.to_maps(category) |> hd
#    cs = Category.changeset(%Category{}, category)
#    if cs.valid? do
#      Changeset.apply_changes(cs)
#    else
#      cs
#    end
  end

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:errors, ...}

  """
  def create_category(attrs \\ %{}) do
    cs = Category.changeset(%Category{}, attrs)
    with true <- cs.valid?,
         %Category{} = site_category <- Changeset.apply_changes(cs),
         {:ok, category} <- DbCategory.new(site_category.name, site_category.categories),
         {:ok, saved_category} <- DbCategory.save_or_update_categories(category)
    do
      {:ok, saved_category}
    else
      _ -> cs = %{cs | action: :create}
           {:errors, cs}
    end
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, ...}

  """
  def update_category(%Category{} = orig_category, attrs) do
    cs = Category.changeset(orig_category, attrs)
    with true <- cs.valid?,
         %Category{} = site_category <- Changeset.apply_changes(cs),
         {:ok, category} <- DbCategory.new(site_category.name, site_category.categories),
         {:ok, saved_category} <- dets_category_update_helper(cs, category, orig_category)
    do
      {:ok, saved_category}
    else
      _ -> cs = %{cs | action: :update}
           {:errors, cs}
    end
  end

  @doc """
  Deletes a Category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, ...}

  """
  def delete_category(%Category{} = category) do
    case DbCategory.delete_category_entry(category.name) do
      :ok -> {:ok, category}
      e -> {:error, e}
    end
  end

  @doc """
  Returns a data structure for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Category{...}

  """
  def change_category(%Category{} = category) do
    Category.changeset(category, %{})
  end
  
  defp dets_category_update_helper(%Changeset{} = cs, %DbCategory{} = category, %Category{} = original) do
    case Changeset.get_change(cs, :name) do
      nil -> DbCategory.save_or_update_categories(category)
      _updated_title -> case delete_category(original) do
                         {:ok, deleted_category} -> DbCategory.save_or_update_categories(category)
                         e -> e
                       end
    end
  end
end
