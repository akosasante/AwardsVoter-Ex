defmodule AwardsVoter.Context.Voting.VotesTest do
  use AwardsVoter.DataCase, async: true

  alias AwardsVoter.Context.Voting.Votes

  describe "Votes.create_vote/1" do
    test "returns applied changes if changeset is valid" do
      attrs = test_vote() |> Map.from_struct()
      refute Map.get(attrs, :__struct__)

      assert {:ok, vote} = Votes.create_vote(attrs)
      assert vote == test_vote()
    end
    test "returns changeset errors if changeset is invalid" do
      attrs = test_vote() |> Map.from_struct() |> Map.update!(:category, fn _ -> nil end)
      refute Map.get(attrs, :__struct__)

      assert {:errors, cs} = Votes.create_vote(attrs)
      refute cs.valid?
      assert cs.action == :create
      assert cs.errors
    end
  end
end