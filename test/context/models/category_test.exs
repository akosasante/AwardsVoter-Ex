defmodule AwardsVoter.Context.Models.CategoryTest do
  use AwardsVoter.DataCase

  alias AwardsVoter.Context.Models.Category

  describe "Category.changeset/2" do
    test "should return valid changeset if params are valid" do
      cs = Category.changeset(%Category{}, params_for(:category, %{has_winner: true}))

      assert cs.valid?
      assert %Ecto.Changeset{} = cs
    end

    test "should return errors if the required params are not provided" do
      category = params_for(:category) |> Map.update!(:name, fn _ -> nil end)
      cs = Category.changeset(%Category{}, category)

      refute cs.valid?
      assert errors_on(cs) == %{name: ["can't be blank"]}
    end
  end

  describe "Category.create/2" do
    test "returns applied changes if changeset is valid" do
      assert {:ok, category} = Category.create(params_for(:category))
      assert category = params_for(:category)
    end

    test "returns changeset errors if changeset is invalid" do
      category = params_for(:category) |> Map.update!(:name, fn _ -> nil end)

      assert {:errors, cs} = Category.create(category)
      refute cs.valid?
      assert cs.action == :create
      assert errors_on(cs) == %{name: ["can't be blank"]}
    end
  end

  describe "Category.update/2" do
    test "returns applied changes if changeset is valid" do
      orig_category_map = params_for(:category)
      updated_category_map = %{orig_category_map | name: "Updated Category"}
      {:ok, updated_category} = Category.create(updated_category_map)
      {:ok, orig_category} = Category.create(orig_category_map)

      assert {:ok, category} = Category.update(orig_category, updated_category_map)
      assert ^category = updated_category
    end

    test "returns changeset errors if changeset is invalid" do
      orig_category_map = params_for(:category)
      updated_category = %{orig_category_map | name: nil}
      {:ok, orig_category} = Category.create(orig_category_map)

      assert {:errors, cs} = Category.update(orig_category, updated_category)
      refute cs.valid?
      assert cs.action == :update
      assert errors_on(cs) == %{name: ["can't be blank"]}
    end
  end
end
