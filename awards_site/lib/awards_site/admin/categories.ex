defmodule AwardsSite.Admin.Categories do
  @moduledoc """
  The Category context.
  """
  
  alias AwardsSite.Admin.Categories.Category
  alias Ecto.Changeset
  
  def create_category(attrs \\ %{}) do
    cs = Category.changeset(%Category{}, attrs)
    if cs.valid? do
      {:ok, Changeset.apply_changes(cs)}
    else
      cs = %{cs | action: :create}
      {:errors, cs}
    end
  end

  def change_category(%Category{} = category) do
    Category.changeset(category, %{})
  end
end
