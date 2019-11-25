defmodule AwardsVoter.BallotTest do
  use ExUnit.Case
  
  alias AwardsVoter.Ballot
  alias AwardsVoter.Category
  alias AwardsVoter.Vote
  
  @test_voter "Tester"
  
  setup do
    categories = [
      %Category{
        contestants: [],
        name: "Album of the Year",
        winner: nil
      },
      %Category{
        contestants: [],
        name: "Record of the Year",
        winner: nil
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
    show = %AwardsVoter.Show{
      categories: categories,
      name: "Grammys 20xx"
    }
    [categories: categories, show: show]
  end

  describe "Ballot.new/2" do
    setup do
      expected = %Ballot{
        voter: @test_voter,
        votes: Map.new([
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
              contestants: [],
              name: "Record of the Year",
              winner: nil
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
        ], fn vote ->{vote.category.name, vote} end)
      }
      [expected: expected]
    end
    test "creates an empty ballot using passed-in show", context do
      assert Ballot.new(@test_voter, context[:show]) == {:ok, context[:expected]}
    end
    
    test "creates an empty ballot using passed-in ncategories", context do
      assert Ballot.new(@test_voter, context[:categories]) == {:ok, context[:expected]}
    end
  end
end
