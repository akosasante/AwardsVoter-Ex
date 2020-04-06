defmodule AwardsVoter.Context.Voting.BallotsTest do
  use AwardsVoter.DataCase, async: true

  alias Ecto.Changeset
  alias AwardsVoter.Context.Voting.Ballots
  alias AwardsVoter.Context.Admin.Categories.Category
  alias AwardsVoter.Context.Admin.Contestants.Contestant

  describe "Ballots.create_ballot/1" do
    test "returns applied changes if changeset is valid" do
      attrs = test_ballot() |> Map.from_struct()
      refute Map.get(attrs, :__struct)

      assert {:ok, ballot}  = Ballots.create_ballot(attrs)
      assert ^ballot = test_ballot()
    end

    test "returns changeset with action :create and errors if invalid" do
      {:errors, cs} = Ballots.create_ballot(%{voter: nil})
      assert %Ecto.Changeset{} = cs
      assert :create = cs.action
      assert cs.errors
    end
  end

  describe "Ballots.get_possible_votes_from_show_or_categories/1" do
    test "takes a list of categories returns a list of blank votes for those categories" do
      categories = test_show().categories
      votes = Ballots.get_possible_votes_from_show_or_categories(categories)
      assert Enum.count(votes) == Enum.count(categories)
      same_categories = votes
        |> Enum.map(fn v -> v.category end)
        |> MapSet.new()
        |> MapSet.equal?(MapSet.new(categories))
      assert same_categories
    end

    test "returns an empty list if an empty category list is passed in" do
      assert [] == Ballots.get_possible_votes_from_show_or_categories([])
    end

    test "returns a list of votes for each category in the passed in show" do
      categories = test_show().categories
      votes = Ballots.get_possible_votes_from_show_or_categories(test_show())
      assert Enum.count(votes) == Enum.count(categories)
      same_categories = votes
                        |> Enum.map(fn v -> v.category end)
                        |> MapSet.new()
                        |> MapSet.equal?(MapSet.new(categories))
      assert same_categories
    end

    test "returns an empty list if a show with no categories is passed in" do
      show = %{test_show() | categories: []}
      assert [] == Ballots.get_possible_votes_from_show_or_categories(show)
    end
  end

  describe "Ballots.create_ballot_from_show_or_categories/2" do
    test "should return {:ok, %Ballot{}} with the appropriate votes and voter" do
      expected = test_ballot()
      assert {:ok, ^expected} = Ballots.create_ballot_from_show_or_categories(test_ballot().voter, test_show())
    end

    test "should return error changeset if the passed in values are insufficient" do
      assert {:errors, %Changeset{}} = Ballots.create_ballot_from_show_or_categories(nil, test_show())
    end
  end

  describe "Ballots.update_ballot/2" do
    test "returns applied changes if changeset is valid" do
      orig_ballot = test_ballot()
      updated_ballot = %{orig_ballot | votes: [test_vote()]}

      attrs = updated_ballot |> Map.from_struct()
      refute Map.get(attrs, :__struct__)

      assert {:ok, ballot} = Ballots.update_ballot(orig_ballot, attrs)
      assert ^ballot = updated_ballot
    end
  end

  describe "Ballots.update_ballot_with_vote/2" do
    test "passed in vote with matching category, updates the vote in the ballot" do
      new_vote = %{test_vote() | contestant: test_contestant()}
      {:ok, updated_ballot} = Ballots.update_ballot_with_vote(test_ballot(), new_vote)
      assert Enum.count(updated_ballot.votes) == Enum.count(test_ballot().votes)
      returned_vote = Enum.find(updated_ballot.votes, fn v -> v.category == test_vote().category end)
      assert returned_vote == new_vote
    end

    test "should returned the same ballot if the vote category doesn't match" do
      new_vote = %{test_vote() | category: %Category{name: "Some Other Category"}}
      {:ok, updated_ballot} = Ballots.update_ballot_with_vote(test_ballot(), new_vote)
      assert updated_ballot == test_ballot()
    end
  end

  describe "Ballots.update_ballot_categories/2" do
    test "updates ballot with new info from passed in categories, leaves other votes unchanged" do
      new_category_1 = %{test_category() | winner: %Contestant{name: "Test Contestant 2"}}
      new_category_2 = %{Enum.at(test_show().categories, 1) | description: "Description #2"}
      {:ok, updated_ballot} = Ballots.update_ballot_categories(test_ballot(), [new_category_1, new_category_2])

      assert Enum.any?(updated_ballot.votes, fn v -> v.category == new_category_1 end)
      assert Enum.any?(updated_ballot.votes, fn v -> v.category == new_category_2 end)
      assert Enum.count(updated_ballot.votes) == Enum.count(test_ballot().votes)
    end
  end

  describe "Ballots.get_vote_by_category/2" do
    test "should return the vote for the matching category if found" do
      vote = Ballots.get_vote_by_category(test_ballot(), test_category().name)
      assert vote.category == test_category()
    end

    test "should return nil if no matching category found" do
      vote = Ballots.get_vote_by_category(test_ballot(), "Invalid Category")
      refute vote
    end
  end
end