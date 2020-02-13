defmodule AwardsVoter.Context.Voting.Votes.VoterTest do
  use ExUnit.Case, async: false

  alias AwardsVoter.Context.Admin.Shows.Show
  alias AwardsVoter.Context.Admin.Categories.Category
  alias AwardsVoter.Context.Admin.Contestants.Contestant
  alias AwardsVoter.Context.Voting.Votes.Voter
  alias AwardsVoter.Context.Voting.Ballots.Ballot
  alias AwardsVoter.Context.Voting.Ballots.BallotState

  @voter_ballot_table Application.get_env(:awards_voter, :voter_ballots_table)

  def setup_dets_file(_context) do
    :dets.open_file(@voter_ballot_table, [])
    on_exit(fn -> :dets.close(@voter_ballot_table) end)
  end

  setup :setup_dets_file

  describe "Voter server callbacks" do
    test "Voter.init, should call itself to setup state, and return the new valid state" do
      categories = [
        %Category{name: "Best Do-er"},
        %Category{name: "Best Say-er"},
        %Category{name: "Best Be-er"}
      ]
      assert {:ok, valid_state} = Voter.init({"Tester", %Show{name: "My Big Music Awards", categories: categories}})
      assert_received({:set_state, "Tester", %Show{name: "My Big Music Awards", categories: categories}})
    end
    test "Voter.init, should call itself to setup fresh state, return :stop tuple if there's an error" do
      assert {:stop, _invalid_state_reason} = Voter.init({"Tester", %Show{name: "My Big Music Awards"}})
      assert_received({:set_state, "Tester", %Show{name: "My Big Music Awards"}})
    end

    test "handle_call :get_ballot, should return a fresh ballot if there's nothing in dets table" do
      :dets.delete_all_objects(@voter_ballot_table)
      state = %Voter.VoterState{
        ballot: %Ballot{voter: "Tester"},
        ballot_state: %BallotState{status: :initialized},
        show: %Show{name: "My Big Music Awards"}
      }

      assert {:reply, :ok, ^state, _timeout} = Voter.handle_call({:get_ballot}, :pid, state)
    end
    test "handle_call :get_ballot, should return the ballot that was saved in DETS" do
      categories = [
        %Category{name: "Best Do-er"},
        %Category{name: "Best Say-er"},
        %Category{name: "Best Be-er"}
      ]
      {:ok, ballot} = Ballot.new("Tester", categories)
      state = %Voter.VoterState{
        ballot: ballot,
        ballot_state: %BallotState{status: :show_set},
        show: %Show{name: "My Big Music Awards", categories: categories}
      }

      :dets.insert(@voter_ballot_table, {"Tester", state})

      assert {:reply, :ok, ^state, _timeout} = Voter.handle_call({:get_ballot}, :pid, %Voter.VoterState{ballot: ballot})
    end

    test "handle_call :reset_show, from allowed state" do
      state = %Voter.VoterState{
        ballot: %Ballot{voter: "Tester"},
        ballot_state: %BallotState{status: :initialized},
        show: %Show{name: "My Big Music Awards"}
      }
      new_show = %Show{name: "My Big Movie Awards"}
      expected_state = %Voter.VoterState{
        ballot: %Ballot{voter: "Tester"},
        ballot_state: %BallotState{status: :show_set},
        show: new_show
      }
      assert {:reply, :ok, ^expected_state, _timeout} = Voter.handle_call({:reset_show, new_show}, :pid, state)
    end
    test "handle_call :reset_show, from illegal state" do
      state = %Voter.VoterState{
        ballot: %Ballot{voter: "Tester"},
        ballot_state: %BallotState{status: :ballot_set},
        show: %Show{name: "My Big Music Awards"}
      }
      new_show = %Show{name: "My Big Movie Awards"}
      assert {:reply, :state_error, ^state, _timeout} = Voter.handle_call({:reset_show, new_show}, :pid, state)
    end

    test "handle_call :reset_ballot, from allowed state" do
      categories = [
        %Category{name: "Best Do-er"},
        %Category{name: "Best Say-er"},
        %Category{name: "Best Be-er"}
      ]
      {:ok, ballot} = Ballot.new("Tester", categories)
      state = %Voter.VoterState{
        ballot: ballot,
        ballot_state: %BallotState{status: :show_set},
        show: %Show{name: "My Big Music Awards", categories: categories}
      }
      {:ok, new_ballot} = Ballot.new("New Tester", categories)
      expected_state = %Voter.VoterState{
        ballot: new_ballot,
        ballot_state: %BallotState{status: :ballot_set},
        show: %Show{name: "My Big Music Awards", categories: categories},
      }
      assert {:reply, :ok, ^expected_state, _timeout} = Voter.handle_call({:reset_ballot, "New Tester"}, :pid, state)
    end
    test "handle_call :reset_ballot, from illegal state" do
      categories = [
        %Category{name: "Best Do-er"},
        %Category{name: "Best Say-er"},
        %Category{name: "Best Be-er"}
      ]
      {:ok, ballot} = Ballot.new("Tester", categories)
      state = %Voter.VoterState{
        ballot: ballot,
        ballot_state: %BallotState{status: :initialized},
        show: %Show{name: "My Big Music Awards", categories: categories}
      }
      assert {:reply, :state_error, ^state, _timeout} = Voter.handle_call({:reset_ballot, "New Tester"}, :pid, state)
    end

    test "handle_call :vote, from allowed state" do
      contestants = make_contestants(["Billie", "Justin", "Lil Nas X"])
      categories = [
        %Category{name: "Best Do-er", contestants: contestants},
        %Category{name: "Best Say-er", contestants: contestants},
        %Category{name: "Best Be-er", contestants: contestants}
      ]
      {:ok, ballot} = Ballot.new("Tester", categories)
      state = %Voter.VoterState{
        ballot: ballot,
        ballot_state: %BallotState{status: :ballot_set},
        show: %Show{name: "My Big Music Awards", categories: categories}
      }
      {:ok, new_ballot} = Ballot.new("Tester", categories)
      billie = Enum.at(contestants, 0)
      new_ballot = put_in(new_ballot.votes["Best Do-er"].contestant, billie)
      expected_state = %Voter.VoterState{
        ballot: new_ballot,
        ballot_state: %BallotState{status: :voting},
        show: %Show{name: "My Big Music Awards", categories: categories},
      }
      assert {:reply, :ok, ^expected_state, _timeout} = Voter.handle_call({:vote, "Best Do-er", "Billie"}, :pid, state)
    end
    test "handle_call :vote, from illegal state" do
      contestants = make_contestants(["Billie", "Justin", "Lil Nas X"])
      categories = [
        %Category{name: "Best Do-er", contestants: contestants},
        %Category{name: "Best Say-er", contestants: contestants},
        %Category{name: "Best Be-er", contestants: contestants}
      ]
      {:ok, ballot} = Ballot.new("Tester", categories)
      state = %Voter.VoterState{
        ballot: ballot,
        ballot_state: %BallotState{status: :show_set},
        show: %Show{name: "My Big Music Awards", categories: categories}
      }
      assert {:reply, :state_error, ^state, _timeout} = Voter.handle_call({:vote, "Best Do-er", "Billie"}, :pid, state)
    end
    test "handle_call :vote, using invalid category name" do
      contestants = make_contestants(["Billie", "Justin", "Lil Nas X"])
      categories = [
        %Category{name: "Best Do-er", contestants: contestants},
        %Category{name: "Best Say-er", contestants: contestants},
        %Category{name: "Best Be-er", contestants: contestants}
      ]
      {:ok, ballot} = Ballot.new("Tester", categories)
      state = %Voter.VoterState{
        ballot: ballot,
        ballot_state: %BallotState{status: :ballot_set},
        show: %Show{name: "My Big Music Awards", categories: categories}
      }
      assert {:reply, :invalid_vote, ^state, _timeout} = Voter.handle_call({:vote, "Best See-er", "Billie"}, :pid, state)
    end
    test "handle_call :vote, using invalid contestant name" do
      contestants = make_contestants(["Billie", "Justin", "Lil Nas X"])
      categories = [
        %Category{name: "Best Do-er", contestants: contestants},
        %Category{name: "Best Say-er", contestants: contestants},
        %Category{name: "Best Be-er", contestants: contestants}
      ]
      {:ok, ballot} = Ballot.new("Tester", categories)
      state = %Voter.VoterState{
        ballot: ballot,
        ballot_state: %BallotState{status: :ballot_set},
        show: %Show{name: "My Big Music Awards", categories: categories}
      }
      assert {:reply, :invalid_vote, ^state, _timeout} = Voter.handle_call({:vote, "Best Do-er", "Jordan"}, :pid, state)
    end

    test "handle_call :submit_ballot, from allowed state" do
      state = %Voter.VoterState{
        ballot: %Ballot{voter: "Tester"},
        ballot_state: %BallotState{status: :voting},
        show: %Show{name: "My Big Music Awards"}
      }
      expected_state = put_in(state.ballot_state.status, :submitted)
      assert {:reply, :ok, ^expected_state, _timeout} = Voter.handle_call({:submit_ballot}, :pid, state)
    end
    test "handle_call :submit_ballot, from illegal state" do
      state = %Voter.VoterState{
        ballot: %Ballot{voter: "Tester"},
        ballot_state: %BallotState{status: :ballot_set},
        show: %Show{name: "My Big Music Awards"}
      }
      assert {:reply, :state_error, ^state, _timeout} = Voter.handle_call({:submit_ballot}, :pid, state)
    end

    test "handle_call :end_show, from allowed state" do
      state = %Voter.VoterState{
        ballot: %Ballot{voter: "Tester"},
        ballot_state: %BallotState{status: :submitted},
        show: %Show{name: "My Big Music Awards"}
      }
      expected_state = put_in(state.ballot_state.status, :show_ended)
      assert {:reply, :ok, ^expected_state, _timeout} = Voter.handle_call({:end_show}, :pid, state)
    end
    test "handle_call :end_show, from illegal state" do
      state = %Voter.VoterState{
        ballot: %Ballot{voter: "Tester"},
        ballot_state: %BallotState{status: :ballot_set},
        show: %Show{name: "My Big Music Awards"}
      }
      assert {:reply, :state_error, ^state, _timeout} = Voter.handle_call({:end_show}, :pid, state)
    end

    test "handle_call :tally, from allowed state" do
      contestants = make_contestants(["Billie", "Justin", "Lil Nas X"])
      categories = [
        %Category{name: "Best Do-er", contestants: contestants},
        %Category{name: "Best Say-er", contestants: contestants},
        %Category{name: "Best Be-er", contestants: contestants}
      ]
      {:ok, ballot} = Ballot.new("Tester", categories)
      state = %Voter.VoterState{
        ballot: ballot,
        ballot_state: %BallotState{status: :submitted},
        show: %Show{name: "My Big Music Awards", categories: categories}
      }
      billie = Enum.at(contestants, 0)
      state = put_in(state.ballot.votes["Best Do-er"].contestant, billie)
      state = put_in(state.ballot.votes["Best Do-er"].category.winner, billie)

      expected_state = put_in(state.score, 1)
      assert {:reply, :ok, ^expected_state, _timeout} = Voter.handle_call({:tally}, :pid, state)
    end
    test "handle_call :tally, from illegal state" do
      contestants = make_contestants(["Billie", "Justin", "Lil Nas X"])
      categories = [
        %Category{name: "Best Do-er", contestants: contestants},
        %Category{name: "Best Say-er", contestants: contestants},
        %Category{name: "Best Be-er", contestants: contestants}
      ]
      {:ok, ballot} = Ballot.new("Tester", categories)
      state = %Voter.VoterState{
        ballot: ballot,
        ballot_state: %BallotState{status: :ballot_set},
        show: %Show{name: "My Big Music Awards", categories: categories}
      }
      billie = Enum.at(contestants, 0)
      state = put_in(state.ballot.votes["Best Do-er"].contestant, billie)
      state = put_in(state.ballot.votes["Best Do-er"].category.winner, billie)

      assert {:reply, :state_error, ^state, _timeout} = Voter.handle_call({:tally}, :pid, state)
    end

    test "handle_info :set_state, should set the state to fresh if nothing found in DETS table" do
      :dets.delete_all_objects(@voter_ballot_table)
      categories = [
        %Category{name: "Best Do-er"},
        %Category{name: "Best Say-er"},
        %Category{name: "Best Be-er"}
      ]
      show = %Show{name: "My Big Music Awards", categories: categories}
      voter = "Tester"
      {:ok, ballot} = Ballot.new(voter, show)

      state = %Voter.VoterState{
        ballot: ballot,
        ballot_state: %BallotState{status: :ballot_set},
        show: show
      }

      assert {:noreply, ^state, _timeout} = Voter.handle_info({:set_state, voter, show}, :some_state)
    end
    test "handle_info :set_state, should set the state to valid existing state if found in DETS table" do

    end
  end

  defp make_contestants(contestant_list) do
    Enum.map(contestant_list, fn contestant_name -> %Contestant{name: contestant_name} end)
  end
end
