defmodule AwardsVoter.Context.Voting.VotesTest do
  use ExUnit.Case, async: true

  alias AwardsVoter.Context.Admin.Categories.Category
  alias AwardsVoter.Context.Admin.Contestants.Contestant
  alias AwardsVoter.Context.Voting.Votes.Vote
  alias AwardsVoter.Context.Voting.Votes

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
      category: %Category{
        contestants: [],
        name: "Songwriter of the Year",
        winner: %Contestant{name: "Billie Eillish"}
      },
      contestant: %Contestant{name: "Justin Bieber"}
    }

    empty_vote = %Vote{
      category: %Category{
        contestants: [],
        name: "Songwriter of the Year",
        winner: nil
      },
      contestant: nil
    }

    empty_vote_with_winner = %Vote{
      category: %Category{
        contestants: [],
        name: "Songwriter of the Year",
        winner: %Contestant{name: "Billie Eillish"}
      },
      contestant: nil
    }

    early_vote = %Vote{
      category: %Category{
        contestants: [],
        name: "Songwriter of the Year",
        winner: nil
      },
      contestant: %Contestant{name: "Billie Eillish"}
    }

    empty_category = %Vote{
      category: nil,
      contestant: nil
    }

    empty_category_with_contestant = %Vote{
      category: nil,
      contestant: %Contestant{name: "Billie Eillish"}
    }

    [
      empty_vote: empty_vote,
      losing_vote: losing_vote,
      winning_vote: winning_vote,
      empty_vote_with_winner: empty_vote_with_winner,
      early_vote: early_vote,
      empty_category: empty_category,
      empty_category_with_contestant: empty_category_with_contestant
    ]
  end

  describe "Votes.is_winning_vote?/1" do
    test "returns false if vote contestant does not match category winner or either is nil",
         context do
      refute Votes.is_winning_vote?(context[:empty_vote])
      refute Votes.is_winning_vote?(context[:empty_vote_with_winner])
      refute Votes.is_winning_vote?(context[:early_vote])
      refute Votes.is_winning_vote?(context[:losing_vote])
      refute Votes.is_winning_vote?(context[:empty_category])
      refute Votes.is_winning_vote?(context[:empty_category_with_contestant])
    end

    test "returns true if vote contestant matches category winner", context do
      assert Votes.is_winning_vote?(context[:winning_vote])
    end
  end

  describe "Votes.vote/2" do
    setup do
      contestants = [
        %Contestant{name: "Billie Eillish"},
        %Contestant{name: "Justin Bieber"},
        %Contestant{name: "Katy Perry"}
      ]

      category = %Category{
        contestants: contestants,
        name: "Songwriter of the Year",
        winner: nil
      }

      {:ok, vote} = Vote.new(category)
      [vote: vote]
    end

    test "returns {:invalid_vote, original vote} if trying to vote for contestant that is not in the passed-in category",
         context do
      {:invalid_vote, vote} = Votes.vote(context[:vote], "Cher")
      assert vote == context[:vote]
      refute vote.contestant
    end

    test "returns :error if vote is nil" do
      assert :error == Votes.vote(nil, "Billie Eillish")
    end

    test "returns {:ok, updated_vote} if vote was valid", context do
      {:ok, vote} = Votes.vote(context[:vote], "Billie Eillish")
      refute vote == context[:vote]
      assert vote.contestant == %Contestant{name: "Billie Eillish"}
    end
  end
end
