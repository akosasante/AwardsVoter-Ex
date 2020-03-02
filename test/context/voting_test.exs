defmodule AwardsVoter.Context.VotingTest do
  use AwardsVoter.DataCase

  import ExUnit.CaptureLog

  alias AwardsVoter.Context.Voting
  alias AwardsVoter.Context.Admin.Contestants.Contestant
  alias Ecto.Changeset

  defmodule MockVoter do
    def save_ballot(_ballot, _show_name) do
      send(self(), :save_ballot)
      :ok
    end

    def list_ballots_for_show(_show_name) do
      winning_vote = %{test_vote() | contestant: test_contestant()}
      new_votes = test_ballot().votes |> Enum.drop(1) |> Enum.concat([winning_vote])
      ballot_with_one_winner = %{test_ballot() | votes: new_votes, voter: "User #2"}
      [test_ballot(), ballot_with_one_winner]
    end
  end

  defmodule MockFailedSaveVoter do
    def save_ballot(_ballot, _show_name), do: {:error, :reason}
    def list_ballots_for_show(show_name), do: MockVoter.list_ballots_for_show(show_name)
  end

  defmodule MockEmptyBallotsVoter do
    def list_ballots_for_show(_show_name), do: []
  end

  defmodule MockShowManager do
    def get(_name), do: test_show()
  end

  defmodule MockShowNotFoundManager do
    def get(_name), do: :not_found
  end

  describe "Voting.create_new_ballot/2" do
    test "should create a blank ballot with no voted-on contestants" do
      Application.put_env(:awards_voter, :voter_mod, MockVoter)
      Application.put_env(:awards_voter, :show_manager_mod, MockShowManager)
      {:ok, saved_ballot} = Voting.create_new_ballot(test_ballot().voter, test_show().name)

      assert saved_ballot == test_ballot()
      assert Enum.all?(saved_ballot.votes, fn v -> is_nil(v.contestant) end)
    end

    test "should return {:error, :show_not_found} if the show name is not found in tables" do
      Application.put_env(:awards_voter, :voter_mod, MockVoter)
      Application.put_env(:awards_voter, :show_manager_mod, MockShowNotFoundManager)
      assert {:error, :show_not_found} = Voting.create_new_ballot(test_ballot().voter, test_show().name)
    end

    test "should return {:error, :ballot_not_saved} if there's an issue saving the ballot" do
      Application.put_env(:awards_voter, :voter_mod, MockFailedSaveVoter)
      Application.put_env(:awards_voter, :show_manager_mod, MockShowManager)
      assert {:error, :ballot_not_saved} = Voting.create_new_ballot(test_ballot().voter, test_show().name)
    end

    test "should return changeset errors if there are changeset errors with the ballot" do
      Application.put_env(:awards_voter, :voter_mod, MockVoter)
      Application.put_env(:awards_voter, :show_manager_mod, MockShowManager)
      assert {:errors, %Changeset{} = cs} = Voting.create_new_ballot(nil, test_show().name)
      refute cs.valid?
    end
  end

  describe "Voting.vote/3" do
    test "should return an updated ballot with the voted contestant set" do
      {:ok, ballot} = Voting.vote(test_ballot(), test_category().name, test_contestant().name)

      assert Enum.count(ballot.votes) == Enum.count(test_ballot().votes)
      assert ballot.votes |> hd |> Map.get(:contestant) == test_contestant()
    end

    test "should return {:invalid_vote, original_ballot} if the category name does not exist in the ballot" do
      assert {:invalid_vote, ballot} = Voting.vote(test_ballot(), "Invalid Category Name", test_contestant().name)

      assert ballot == test_ballot()
    end

    test "should return {:invalid_vote, original_ballot} if contestant name is not found in ballot" do
      assert {:invalid_vote, ballot} = Voting.vote(test_ballot(), test_category().name, "Invalid Name")

      assert ballot == test_ballot()
    end
    test "should return {:invalid_vote, original_ballot} if contestant name is nil" do
      assert {:invalid_vote, ballot} = Voting.vote(test_ballot(), test_category().name, nil)

      assert ballot == test_ballot()
    end
  end

  describe "Voting.vote/2" do
    test "should return a vote with the contestant updated if the name matches" do
      expected_vote = %{test_vote() | contestant: test_contestant()}
      {:ok, vote} = Voting.vote(test_vote(), test_contestant().name)

      assert vote == expected_vote
    end

    test "should return {:invalid_vote, original_vote} if the contestant name doesn't match" do
      assert {:invalid_vote, vote} = Voting.vote(test_vote(), "Invalid Contestant Name")

      assert vote == test_vote()
    end

    test "should return :error if nil vote is passed in" do
      assert :error = Voting.vote(nil, test_contestant().name)
    end
  end

  describe "Voting.multi_vote/2" do
    test "should update the contestant for all votes passed in and return the final ballot" do
      vote_map = %{
        test_category().name => test_contestant().name,
      }

      assert {:ok, ballot} = Voting.multi_vote(test_ballot(), vote_map)
      assert Enum.count(ballot.votes) == Enum.count(test_ballot().votes)
      assert ballot.votes |> hd |> Map.get(:contestant) == test_contestant()
      assert ballot.votes |> Enum.at(1) |> Map.get(:contestant) |> is_nil
    end

    test "should return error tuple if any single vote fails to work" do
      vote_map = %{
        test_category().name => test_contestant().name,
        "Test Category 2" => "Invalid Contestant",
        "Invalid Category" => test_contestant().name
      }

      assert {:invalid_vote, ballot} = Voting.multi_vote(test_ballot(), vote_map)
      assert ballot == test_ballot()
    end
  end

  describe "Voting.is_winning_vote?/1" do
    test "should return true if the vote category's winner matches the vote contestant" do
      vote = %{test_vote() | contestant: test_contestant()}
      assert Voting.is_winning_vote?(vote)
    end

    test "should return false if the vote category's winner doesn't match the vote contestant" do
      vote = %{test_vote() | contestant: %Contestant{name: "Test Contestant 2"}}
      refute Voting.is_winning_vote?(vote)
    end

    test "should return false if the vote category's winner was nil" do
      category_without_winner_set = %{test_category() | winner: nil}
      vote = %{test_vote() | category: category_without_winner_set, contestant: test_contestant()}
      refute Voting.is_winning_vote?(vote)
    end

    test "should return false if the vote contestant was nil" do
      refute Voting.is_winning_vote?(test_vote())
    end

    test "should return false if the vote category was nil" do
      vote = %{test_vote() | category: nil, contestant: test_contestant()}
      refute Voting.is_winning_vote?(vote)
    end
  end

  describe "Voting.score/1" do
    test "should return the correct value for the number of winning votes" do
      winning_vote = %{test_vote() | contestant: test_contestant()}
      new_votes = test_ballot().votes |> Enum.drop(1) |> Enum.concat([winning_vote])
      ballot_with_one_winner = %{test_ballot() | votes: new_votes}

      assert {:ok, 0} == Voting.score(test_ballot())
      assert {:ok, 1} == Voting.score(ballot_with_one_winner)
    end
  end

  describe "Voting.get_scores_for_show/1" do
    test "return a list of {voter_name, score} for that ballots of that show" do
      Application.put_env(:awards_voter, :voter_mod, MockVoter)
      expected = [{test_ballot().voter, 0}, {"User #2", 1}]
      res = Voting.get_scores_for_show(test_show().name)

      assert res == expected
    end
    test "return an empty list if there are no ballots for that show" do
      Application.put_env(:awards_voter, :voter_mod, MockEmptyBallotsVoter)
      res = Voting.get_scores_for_show(test_show().name)

      assert Enum.count(res) == 0
    end
  end

  describe "Voting.update_ballots_for_show/1" do
    test "should call save_ballot for each ballot for that show" do
      Application.put_env(:awards_voter, :voter_mod, MockVoter)
      assert :ok = Voting.update_ballots_for_show(test_show())
      for _ <- 1..2 do
        assert_received :save_ballot
      end
      refute_received :save_ballot
    end

    test "logs any errors for failed saves but still return successfully" do
      Application.put_env(:awards_voter, :voter_mod, MockFailedSaveVoter)

      assert capture_log(fn ->
        assert :ok = Voting.update_ballots_for_show(test_show())
      end) =~ "Unable to update ballot"
    end
  end
end