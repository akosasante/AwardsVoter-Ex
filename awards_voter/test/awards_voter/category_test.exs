defmodule AwardsVoter.CategoryTest do
  use ExUnit.Case, async: true
  
  alias AwardsVoter.{Category, Contestant}
  
  describe "Category.new/4" do
    setup do
      expected = %Category{
        contestants: [
          %Contestant{name: "Billie", wiki_url: "www.wikipedia.org"},
          %Contestant{name: "Justin", youtube_url: "www.youtube.com"}
        ],
        name: "Best Test",
        winner: nil,
        description: "Who da best test"
      }

      [expected: expected]
    end
    
    test "converts all of the passed in contestant Maps to %Contestant{} structs", context do
      contestants = [
        %Contestant{name: "Billie", wiki_url: "www.wikipedia.org"},
        %{name: "Justin", youtube_url: "www.youtube.com"}
      ]
      
      assert Category.new("Best Test", contestants, "Who da best test") == {:ok, context[:expected]}
    end
  end
end