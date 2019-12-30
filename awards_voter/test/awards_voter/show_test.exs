defmodule AwardsVoter.ShowTest do
  use ExUnit.Case, async: true

  alias AwardsVoter.{Show, Category}

  describe "Show.new/2" do
    setup do
      expected = %Show{
        categories: [
          %Category{name: "Billie", description: "She's a bad guy"},
          %Category{name: "Justin", description: "He's a bad guy too sometimes"}
        ],
        name: "The Test Show",
      }

      [expected: expected]
    end

    test "converts all of the passed in category Maps to %Category{} structs", context do
      categories = [
        %Category{name: "Billie", description: "She's a bad guy"},
        %{name: "Justin", description: "He's a bad guy too sometimes"}
      ]

      assert Show.new("The Test Show", categories) == {:ok, context[:expected]}
    end
  end
end