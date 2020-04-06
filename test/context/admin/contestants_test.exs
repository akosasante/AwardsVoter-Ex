defmodule AwardsVoter.Context.Admin.ContestantsTest do
  use AwardsVoter.DataCase, async: true

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Admin.Contestants

  describe "Contestants.create_contestant/2" do
    test "returns applied changes if changeset is valid" do
      attrs = test_contestant() |> Admin.contestant_to_map()
      refute Map.get(attrs, :__struct__)

      assert {:ok, contestant} = Contestants.create_contestant(attrs)
      assert contestant = test_contestant()
    end

    test "returns changeset errors if changeset is invalid" do
      attrs = test_contestant() |> Map.update!(:name, fn _ -> nil end) |> Admin.contestant_to_map()
      refute Map.get(attrs, :__struct__)

      assert {:errors, cs} = Contestants.create_contestant(attrs)
      refute cs.valid?
      assert cs.action == :create
      assert cs.errors
    end
  end

  describe "Contestants.update_contestant/3" do
    test "returns applied changes if changeset is valid" do
      orig_contestant = test_contestant()
      updated_contestant =  %{orig_contestant | name: "Updated Contestant"}
      attrs = updated_contestant |> Admin.contestant_to_map()
      refute Map.get(attrs, :__struct__)

      assert {:ok, contestant} = Contestants.update_contestant(orig_contestant, attrs)
      assert ^contestant = updated_contestant
    end

    test "returns changeset errors if changeset is invalid" do
      orig_contestant = test_contestant()
      updated_contestant =  %{orig_contestant | name: nil}
      attrs = updated_contestant |> Admin.contestant_to_map()
      refute Map.get(attrs, :__struct__)

      assert {:errors, cs} = Contestants.update_contestant(orig_contestant, attrs)
      refute cs.valid?
      assert cs.action == :update
      assert cs.errors
    end
  end
end