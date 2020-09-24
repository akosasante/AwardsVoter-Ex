defmodule AwardsVoter.Context.Models.VoteTest do
  use AwardsVoter.DataCase

  alias AwardsVoter.Context.Models.Vote

  describe "Vote.changeset/2" do
    test "should return valid changeset if params are valid" do
      cs = Vote.changeset(%Vote{}, params_for(:vote))

      assert cs.valid?
      assert %Ecto.Changeset{} = cs
    end

    test "should return errors if the required params are not provided" do
      vote = params_for(:vote) |> Map.update!(:category, fn _ -> nil end)
      cs = Vote.changeset(%Vote{}, vote)

      refute cs.valid?
      assert errors_on(cs) == %{category: ["can't be blank"]}
    end
  end

  describe "Vote.create/2" do
    test "returns applied changes if changeset is valid" do
      assert {:ok, vote} = Vote.create(params_for(:vote))
      assert vote = params_for(:vote)
    end

    test "returns changeset errors if changeset is invalid" do
      vote = params_for(:vote) |> Map.update!(:category, fn _ -> nil end)

      assert {:errors, cs} = Vote.create(vote)
      refute cs.valid?
      assert cs.action == :create
      assert errors_on(cs) == %{category: ["can't be blank"]}
    end
  end

  describe "Vote.update/2" do
    test "returns applied changes if changeset is valid" do
      orig_vote_map = params_for(:vote)
      updated_vote_map = %{orig_vote_map | category: params_for(:category)}
      {:ok, updated_vote} = Vote.create(updated_vote_map)
      {:ok, orig_vote} = Vote.create(orig_vote_map)

      assert {:ok, vote} = Vote.update(orig_vote, updated_vote_map)
      assert ^vote = updated_vote
    end

    test "returns changeset errors if changeset is invalid" do
      orig_vote_map = params_for(:vote)
      updated_vote = %{orig_vote_map | category: nil}
      {:ok, orig_vote} = Vote.create(orig_vote_map)

      assert {:errors, cs} = Vote.update(orig_vote, updated_vote)
      refute cs.valid?
      assert cs.action == :update
      assert errors_on(cs) == %{category: ["can't be blank"]}
    end
  end
end
