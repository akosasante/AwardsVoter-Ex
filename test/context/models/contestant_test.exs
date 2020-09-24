defmodule AwardsVoter.Context.Models.ContestantTest do
  use AwardsVoter.DataCase

  alias AwardsVoter.Context.Models.Contestant

  describe "Contestant.changeset/2" do
    test "should return valid changeset if params are valid" do
      cs = Contestant.changeset(%Contestant{}, params_for(:contestant))

      assert cs.valid?
      assert %Ecto.Changeset{} = cs
    end

    test "should return errors if the required params are not provided" do
      contestant = params_for(:contestant) |> Map.update!(:name, fn _ -> nil end)
      cs = Contestant.changeset(%Contestant{}, contestant)

      refute cs.valid?
      assert errors_on(cs) == %{name: ["can't be blank"]}
    end
  end

  describe "Contestant.create/2" do
    test "returns applied changes if changeset is valid" do
      assert {:ok, contestant} = Contestant.create(params_for(:contestant))
      assert contestant = params_for(:contestant)
    end

    test "returns changeset errors if changeset is invalid" do
      contestant = params_for(:contestant) |> Map.update!(:name, fn _ -> nil end)

      assert {:errors, cs} = Contestant.create(contestant)
      refute cs.valid?
      assert cs.action == :create
      assert errors_on(cs) == %{name: ["can't be blank"]}
    end
  end

  describe "Contestant.update/2" do
    test "returns applied changes if changeset is valid" do
      orig_contestant = build(:contestant)
      updated_contestant = %{orig_contestant | name: "Updated Contestant"} |> Map.from_struct()

      assert {:ok, contestant} = Contestant.update(orig_contestant, updated_contestant)
      assert ^contestant = struct!(%Contestant{}, updated_contestant)
    end

    test "returns changeset errors if changeset is invalid" do
      orig_contestant = build(:contestant)
      updated_contestant = %{orig_contestant | name: nil} |> Map.from_struct()

      assert {:errors, cs} = Contestant.update(orig_contestant, updated_contestant)
      refute cs.valid?
      assert cs.action == :update
      assert errors_on(cs) == %{name: ["can't be blank"]}
    end
  end
end
