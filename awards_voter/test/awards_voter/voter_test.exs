defmodule AwardsVoter.VoterTest do
  use ExUnit.Case, async: true
  
  alias AwardsVoter.{Voter, BallotState, Ballot, Show, Category, Contestant}
  
  describe "Voter server callbacks (handle_call)" do
    test ":reset_voter, from allowed state" do
      state = %Voter.VoterState{
        ballot: %Ballot{voter: "Tester"}, # TODO: This should actually wipe the whole slate clean except for maybe ballot name
        ballot_state: %BallotState{status: :show_set}
      }
      expected_state = %Voter.VoterState{
        ballot: %Ballot{voter: "Tester"},
        ballot_state: %BallotState{status: :initialized}
      }
      assert {:reply, :ok, ^expected_state, _timeout} = Voter.handle_call({:reset_voter}, :pid, state)
    end
    test ":reset_voter, from illegal state" do
      state = %Voter.VoterState{
        ballot: %Ballot{voter: "Tester"},
        ballot_state: %BallotState{status: :show_ended}
      }
      assert {:reply, :state_error, ^state, _timeout} = Voter.handle_call({:reset_voter}, :pid, state)
    end

    test ":reset_show, from allowed state" do
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
    test ":reset_show, from illegal state" do
      state = %Voter.VoterState{
        ballot: %Ballot{voter: "Tester"},
        ballot_state: %BallotState{status: :ballot_set},
        show: %Show{name: "My Big Music Awards"}
      }
      new_show = %Show{name: "My Big Movie Awards"}
      assert {:reply, :state_error, ^state, _timeout} = Voter.handle_call({:reset_show, new_show}, :pid, state)
    end

    test ":reset_ballot, from allowed state" do
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
    test ":reset_ballot, from illegal state" do
      categories = [
        %Category{name: "Best Do-er"},
        %Category{name: "Best Say-er"},
        %Category{name: "Best Be-er"}
      ]
      {:ok, ballot} = Ballot.new("Tester", categories)
      state = %Voter.VoterState{
        ballot: ballot,
        ballot_state: %BallotState{status: :voting},
        show: %Show{name: "My Big Music Awards", categories: categories}
      }
      assert {:reply, :state_error, ^state, _timeout} = Voter.handle_call({:reset_ballot, "New Tester"}, :pid, state)
    end

    test ":vote, from allowed state" do
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
    test ":vote, from illegal state" do
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
    test ":vote, using invalid category name" do
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
    test ":vote, using invalid contestant name" do
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

    test ":submit_ballot, from allowed state" do
      state = %Voter.VoterState{
        ballot: %Ballot{voter: "Tester"},
        ballot_state: %BallotState{status: :voting},
        show: %Show{name: "My Big Music Awards"}
      }
      expected_state = put_in(state.ballot_state.status, :submitted)
      assert {:reply, :ok, ^expected_state, _timeout} = Voter.handle_call({:submit_ballot}, :pid, state)
    end
    test ":submit_ballot, from illegal state" do
      state = %Voter.VoterState{
        ballot: %Ballot{voter: "Tester"},
        ballot_state: %BallotState{status: :ballot_set},
        show: %Show{name: "My Big Music Awards"}
      }
      assert {:reply, :state_error, ^state, _timeout} = Voter.handle_call({:submit_ballot}, :pid, state)
    end

    test ":end_show, from allowed state" do
      state = %Voter.VoterState{
        ballot: %Ballot{voter: "Tester"},
        ballot_state: %BallotState{status: :submitted},
        show: %Show{name: "My Big Music Awards"}
      }
      expected_state = put_in(state.ballot_state.status, :show_ended)
      assert {:reply, :ok, ^expected_state, _timeout} = Voter.handle_call({:end_show}, :pid, state)
    end
    test ":end_show, from illegal state" do
      state = %Voter.VoterState{
        ballot: %Ballot{voter: "Tester"},
        ballot_state: %BallotState{status: :ballot_set},
        show: %Show{name: "My Big Music Awards"}
      }
      assert {:reply, :state_error, ^state, _timeout} = Voter.handle_call({:end_show}, :pid, state)
    end

    test ":tally, from allowed state" do
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
    test ":tally, from illegal state" do
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
  end

  defp make_contestants(contestant_list) do
    Enum.map(contestant_list, fn contestant_name -> Contestant.new(contestant_name) end)
    |> Enum.map(fn {:ok, contestant} -> contestant end)
  end
end

