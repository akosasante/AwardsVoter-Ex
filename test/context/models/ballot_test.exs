defmodule AwardsVoter.Context.Models.BallotTest do
  use AwardsVoter.DataCase

  alias AwardsVoter.Context.Models.Ballot

  describe "Ballot.changeset/2" do
    test "should return valid changeset if params are valid" do
      cs = Ballot.changeset(%Ballot{}, params_for(:ballot))

      assert cs.valid?
      assert %Ecto.Changeset{} = cs
    end

    test "should return errors if the required params are not provided" do
      ballot = params_for(:ballot) |> Map.update!(:voter, fn _ -> nil end)
      cs = Ballot.changeset(%Ballot{}, ballot)

      refute cs.valid?
      assert errors_on(cs) == %{voter: ["can't be blank"]}
    end
  end

  describe "Ballot.create/2" do
    test "returns applied changes if changeset is valid" do
      assert {:ok, ballot} = Ballot.create(params_for(:ballot))
      assert ballot = params_for(:ballot)
    end

    test "returns changeset errors if changeset is invalid" do
      ballot = params_for(:ballot) |> Map.update!(:voter, fn _ -> nil end)

      assert {:errors, cs} = Ballot.create(ballot)
      refute cs.valid?
      assert cs.action == :create
      assert errors_on(cs) == %{voter: ["can't be blank"]}
    end
  end

  describe "Ballot.update/2" do
    test "returns applied changes if changeset is valid" do
      orig_ballot_map = params_for(:ballot)
      updated_ballot_map = %{orig_ballot_map | voter: "Updated Ballot"}
      {:ok, updated_ballot} = Ballot.create(updated_ballot_map)
      {:ok, orig_ballot} = Ballot.create(orig_ballot_map)

      assert {:ok, ballot} = Ballot.update(orig_ballot, updated_ballot_map)
      assert ^ballot = updated_ballot
    end

    test "returns changeset errors if changeset is invalid" do
      orig_ballot_map = params_for(:ballot)
      updated_ballot = %{orig_ballot_map | voter: nil}
      {:ok, orig_ballot} = Ballot.create(orig_ballot_map)

      assert {:errors, cs} = Ballot.update(orig_ballot, updated_ballot)
      refute cs.valid?
      assert cs.action == :update
      assert errors_on(cs) == %{voter: ["can't be blank"]}
    end
  end
end
