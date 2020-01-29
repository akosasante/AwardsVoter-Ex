defmodule AwardsVoter.Context.Voting.Ballots.BallotTest do
  use ExUnit.Case, async: true

  alias AwardsVoter.Context.Admin.Categories.Category
  alias AwardsVoter.Context.Admin.Contestants.Contestant
  alias AwardsVoter.Context.Admin.Shows.Show
  alias AwardsVoter.Context.Voting.Ballots.Ballot
  alias AwardsVoter.Context.Voting.Votes.Vote

  @test_voter "Tester"

  setup do
    categories = [
      %Category{
        contestants: [],
        name: "Album of the Year",
        winner: nil
      },
      %Category{
        contestants: [
          %Contestant{name: "Billie Eillish"},
          %Contestant{name: "Justin Bieber"},
          %Contestant{name: "Katy Perry"}
        ],
        name: "Record of the Year",
        winner: %Contestant{name: "Billie Eillish"}
      },
      %Category{
        contestants: [],
        name: "Artist of the Year",
        winner: nil
      },
      %Category{
        contestants: [],
        name: "Songwriter of the Year",
        winner: nil
      }
    ]

    show = %Show{
      categories: categories,
      name: "Grammys 20xx"
    }

    [categories: categories, show: show]
  end

  describe "Ballot.new/2" do
    setup do
      expected = %Ballot{
        voter: @test_voter,
        votes:
          Map.new(
            [
              %Vote{
                category: %Category{
                  contestants: [],
                  name: "Album of the Year",
                  winner: nil
                },
                contestant: nil
              },
              %Vote{
                category: %Category{
                  contestants: [],
                  name: "Artist of the Year",
                  winner: nil
                },
                contestant: nil
              },
              %Vote{
                category: %Category{
                  contestants: [
                    %Contestant{name: "Billie Eillish"},
                    %Contestant{name: "Justin Bieber"},
                    %Contestant{name: "Katy Perry"}
                  ],
                  name: "Record of the Year",
                  winner: %Contestant{name: "Billie Eillish"}
                },
                contestant: nil
              },
              %Vote{
                category: %Category{
                  contestants: [],
                  name: "Songwriter of the Year",
                  winner: nil
                },
                contestant: nil
              }
            ],
            fn vote -> {vote.category.name, vote} end
          )
      }

      [expected: expected]
    end

    test "creates an empty ballot using passed-in show", context do
      assert Ballot.new(@test_voter, context[:show]) == {:ok, context[:expected]}
    end

    test "creates an empty ballot using passed-in categories", context do
      assert Ballot.new(@test_voter, context[:categories]) == {:ok, context[:expected]}
    end
  end

  describe "Ballot.vote/2" do
    test "returns {:ok, updated_ballot} when a valid vote is attempted", context do
      {:ok, orig_ballot} = Ballot.new(@test_voter, context[:show])
      {:ok, ballot} = Ballot.vote(orig_ballot, "Record of the Year", "Billie Eillish")
      refute ballot == orig_ballot
      assert ballot.votes["Record of the Year"].contestant.name == "Billie Eillish"
    end

    test "returns the original ballot with an invalid_vote atom if an invalid contestant is attempted",
         context do
      {:ok, orig_ballot} = Ballot.new(@test_voter, context[:show])
      {:invalid_vote, ballot} = Ballot.vote(orig_ballot, "Record of the Year", "Yung Nudy")
      assert ballot == orig_ballot
      refute ballot.votes["Movie of the Year"]
    end

    test "returns the original ballot with an invalid_vote atom if an invalid category is attempted",
         context do
      {:ok, orig_ballot} = Ballot.new(@test_voter, context[:show])
      {:invalid_vote, ballot} = Ballot.vote(orig_ballot, "Movie of the Year", "Billie Eillish")
      assert ballot == orig_ballot
      refute ballot.votes["Movie of the Year"]
    end
  end

  describe "Ballot.score/1" do
    test "Should return 0 for a fresh ballot", context do
      {:ok, ballot} = Ballot.new(@test_voter, context[:show])
      assert {:ok, 0} == Ballot.score(ballot)
    end

    test "Should return number of winning votes on ballot", context do
      {:ok, ballot} = Ballot.new(@test_voter, context[:show])
      {:ok, ballot} = Ballot.vote(ballot, "Record of the Year", "Billie Eillish")
      assert {:ok, 1} == Ballot.score(ballot)
    end
  end
end
