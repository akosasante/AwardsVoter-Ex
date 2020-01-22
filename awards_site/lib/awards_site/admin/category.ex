defmodule AwardsSite.Admin.Category do
  @moduledoc """
  The Category context.
  """
  
  alias AwardsSite.CategoryModel
  alias AwardsSite.CategoryModel
  alias AwardsVoter.Category, as: DbCategory
  alias Ecto.Changeset

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%CategoryModel{}, ...]

  """
  def list_categories do
    {:ok, all_categories} = DbCategory.get_all_categories()
    all_categories
    |> DbCategory.to_maps()
    |> Enum.map(fn db_category -> 
      cs = CategoryModel.changeset(%CategoryModel{}, db_category)
      if cs.valid? do
        Changeset.apply_changes(cs)
      else
        cs
      end
    end)
  end

  @doc """
  Gets a single category.

  Raises if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %CategoryModel{}

  """
  def get_category!(name) do
    {:ok, category} = DbCategory.get_category_by_name(name)
    category = DbCategory.to_maps(category) |> hd
    cs = CategoryModel.changeset(%CategoryModel{}, category)
    if cs.valid? do
      Changeset.apply_changes(cs)
    else
      cs
    end
  end

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %CategoryModel{}}

      iex> create_category(%{field: bad_value})
      {:errors, ...}

  """
  def create_category(attrs \\ %{}) do
    cs = CategoryModel.changeset(%CategoryModel{}, attrs)
    with true <- cs.valid?,
         %CategoryModel{} = site_category <- Changeset.apply_changes(cs),
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
      {:ok, %CategoryModel{}}

      iex> update_category(category, %{field: bad_value})
      {:error, ...}

  """
  def update_category(%CategoryModel{} = orig_category, attrs) do
    cs = CategoryModel.changeset(orig_category, attrs)
    with true <- cs.valid?,
         %CategoryModel{} = site_category <- Changeset.apply_changes(cs),
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
      {:ok, %CategoryModel{}}

      iex> delete_category(category)
      {:error, ...}

  """
  def delete_category(%CategoryModel{} = category) do
    case DbCategory.delete_category_entry(category.name) do
      :ok -> {:ok, category}
      e -> {:error, e}
    end
  end

  @doc """
  Returns a data structure for tracking category changes.

  ## Examples

      iex> change_category(category)
      %CategoryModel{...}

  """
  def change_category(%CategoryModel{} = category) do
    CategoryModel.changeset(category, %{})
  end
  
  defp dets_category_update_helper(%Changeset{} = cs, %DbCategory{} = category, %CategoryModel{} = original) do
    case Changeset.get_change(cs, :name) do
      nil -> DbCategory.save_or_update_categories(category)
      _updated_title -> case delete_category(original) do
                         {:ok, deleted_category} -> DbCategory.save_or_update_categories(category)
                         e -> e
                       end
    end
  end
end
