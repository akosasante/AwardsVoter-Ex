defmodule AwardsVoter.VoteTest do
  use ExUnit.Case
  
  alias AwardsVoter.Vote
  alias AwardsVoter.Category
  alias AwardsVoter.Contestant
  
  setup do
    winning_vote = %Vote{
      category: %Category{
        contestants: [],
        name: "Songwriter of the Year",
        winner: %Contestant{name: "Billie Eillish"}
      },
      contestant: %Contestant{name: "Billie Eillish"}
    }

    losing_vote = %Vote{
      category: %AwardsVoter.Category{
        contestants: [],
        name: "Songwriter of the Year",
        winner: %Contestant{name: "Billie Eillish"}
      },
      contestant: %Contestant{name: "Justin Bieber"}
    }
    
    empty_vote = %Vote{
      category: %AwardsVoter.Category{
        contestants: [],
        name: "Songwriter of the Year",
        winner: nil
      },
      contestant: nil
    }

    empty_vote_with_winner = %Vote{
      category: %AwardsVoter.Category{
        contestants: [],
        name: "Songwriter of the Year",
        winner: %Contestant{name: "Billie Eillish"}
      },
      contestant: nil
    }
    
    early_vote = %Vote{
      category: %AwardsVoter.Category{
        contestants: [],
        name: "Songwriter of the Year",
        winner: nil
      },
      contestant: %Contestant{name: "Billie Eillish"}
    }

    [empty_vote: empty_vote, losing_vote: losing_vote, winning_vote: winning_vote, empty_vote_with_winner: empty_vote_with_winner, early_vote: early_vote]
  end
  
  describe "Vote.is_winning_vote?/1" do
    test "returns false if vote contestant does not match category winner or either is nil", context do
      refute Vote.is_winning_vote?(context[:empty_vote])
      refute Vote.is_winning_vote?(context[:empty_vote_with_winner])
      refute Vote.is_winning_vote?(context[:early_vote])
      refute Vote.is_winning_vote?(context[:losing_vote])
      
    end
    test "returns true if vote contestant matches category winner", context do
      assert Vote.is_winning_vote?(context[:winning_vote])
    end
  end
end