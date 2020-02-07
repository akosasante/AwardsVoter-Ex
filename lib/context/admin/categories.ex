defmodule AwardsVoter.Context.Admin.Categories do
  @moduledoc """
  The Category context.
  """

  alias AwardsVoter.Context.Admin.Categories.Category
  alias Ecto.Changeset
  
  @type change_result :: {:ok, Category.t()} | {:errors, Changeset.t()}

  @spec create_category(map()) :: change_result
  def create_category(attrs \\ %{}) do
    cs = Category.changeset(%Category{}, attrs)
    if cs.valid? do
      {:ok, Changeset.apply_changes(cs)}
    else
      cs = %{cs | action: :create}
      {:errors, cs}
    end
  end

  @spec update_category(Category.t(), map()) :: change_result
  def update_category(%Category{} = orig_category, attrs) do
    cs = Category.changeset(orig_category, attrs)
    if cs.valid? do
      {:ok, Changeset.apply_changes(cs)}
    else
      cs = %{cs | action: :update}
      {:errors, cs}
    end
  end

  @spec change_category(Category.t()) :: Changeset.t()
  def change_category(%Category{} = category) do
    Category.changeset(category, %{})
  end
end