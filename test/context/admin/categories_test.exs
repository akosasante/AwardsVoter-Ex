defmodule AwardsVoter.Context.Admin.CategoriesTest do
  use AwardsVoter.DataCase, async: true

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Admin.Categories

  describe "Categories.create_category/2" do
    test "returns applied changes if changeset is valid" do
      attrs = test_category() |> Admin.category_to_map()
      refute Map.get(attrs, :__struct__)

      assert {:ok, category} = Categories.create_category(attrs)
      assert ^category = test_category()
    end

    test "returns changeset errors if changeset is invalid" do
      attrs = test_category() |> Map.update!(:name, fn _ -> nil end) |> Admin.category_to_map()
      refute Map.get(attrs, :__struct__)

      assert {:errors, cs} = Categories.create_category(attrs)
      refute cs.valid?
      assert cs.action == :create
      assert cs.errors
    end
  end

  describe "Categories.update_category/3" do
    test "returns applied changes if changeset is valid" do
      orig_category = test_category()
      updated_category =  %{orig_category | name: "Updated Category"}
      attrs = updated_category |> Admin.category_to_map()
      refute Map.get(attrs, :__struct__)

      assert {:ok, category} = Categories.update_category(orig_category, attrs)
      assert ^category = updated_category
    end

    test "returns changeset errors if changeset is invalid" do
      orig_category = test_category()
      updated_category =  %{orig_category | name: nil}
      attrs = updated_category |> Admin.category_to_map()
      refute Map.get(attrs, :__struct__)

      assert {:errors, cs} = Categories.update_category(orig_category, attrs)
      refute cs.valid?
      assert cs.action == :update
      assert cs.errors
    end
  end
end