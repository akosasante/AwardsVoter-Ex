defmodule AwardsVoter.Context.Voting.Votes.VotesTest do
  use AwardsVoter.DataCase, async: true
  
  alias AwardsVoter.Context.Voting.Votes.Vote
  
  describe "Vote.changeset/2" do
    test "should put the category in with put_embed" do
      cs = Vote.changeset(%Vote{}, %{category: test_category()})
      
      assert cs.valid?
      assert cs.changes.category.valid?
      assert cs.changes.category.data == test_category()
    end
    
    test "should put the contestant in with put_embed" do
      cs = Vote.changeset(%Vote{}, %{category: test_category(), contestant: test_contestant()})

      assert cs.valid?
      assert cs.changes.contestant.valid?
      assert cs.changes.contestant.data == test_contestant()
    end
    
    test "should return valid changeset if params are valid" do
      cs = Vote.changeset(%Vote{}, %{category: test_category(), contestant: test_contestant()})

      assert cs.valid?
      assert %Ecto.Changeset{} = cs
    end
    
    test "should return errors if the category is not provided" do
      cs = Vote.changeset(%Vote{}, %{contestant: test_contestant()})
      errors = Ecto.Changeset.traverse_errors(cs, fn {msg, _opts} -> msg end)

      refute cs.valid?
      assert errors == %{category: ["can't be blank"]}
    end
  end
end
