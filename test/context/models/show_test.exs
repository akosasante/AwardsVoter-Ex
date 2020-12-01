defmodule AwardsVoter.Context.Models.ShowTest do
  use AwardsVoter.DataCase

  alias AwardsVoter.Context.Models.Show

  describe "Show.changeset/2" do
    test "should return valid changeset if params are valid" do
      cs = Show.changeset(%Show{}, params_for(:show))

      assert cs.valid?
      assert %Ecto.Changeset{} = cs
    end

    test "should return errors if the required params are not provided" do
      show = params_for(:show) |> Map.update!(:name, fn _ -> nil end)
      cs = Show.changeset(%Show{}, show)

      refute cs.valid?
      assert errors_on(cs) == %{name: ["can't be blank"]}
    end
  end

  describe "Show.create/2" do
    test "returns applied changes if changeset is valid" do
      assert {:ok, show} = Show.create(params_for(:show))
      assert show = params_for(:show)
    end

    test "returns changeset errors if changeset is invalid" do
      show = params_for(:show) |> Map.update!(:name, fn _ -> nil end)

      assert {:errors, cs} = Show.create(show)
      refute cs.valid?
      assert cs.action == :create
      assert errors_on(cs) == %{name: ["can't be blank"]}
    end
  end

  describe "Show.update/2" do
    test "returns applied changes if changeset is valid" do
      orig_show_map = params_for(:show)
      updated_show_map = %{orig_show_map | name: "Updated Show"}
      {:ok, updated_show} = Show.create(updated_show_map)
      {:ok, orig_show} = Show.create(orig_show_map)

      assert {:ok, show} = Show.update(orig_show, updated_show_map)
      assert ^show = updated_show
    end

    test "returns changeset errors if changeset is invalid" do
      orig_show_map = params_for(:show)
      updated_show = %{orig_show_map | name: nil}
      {:ok, orig_show} = Show.create(orig_show_map)

      assert {:errors, cs} = Show.update(orig_show, updated_show)
      refute cs.valid?
      assert cs.action == :update
      assert errors_on(cs) == %{name: ["can't be blank"]}
    end
  end
end
