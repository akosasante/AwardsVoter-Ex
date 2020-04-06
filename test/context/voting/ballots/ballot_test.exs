defmodule AwardsVoter.Context.Voting.Ballots.BallotTest do
  use AwardsVoter.DataCase

  alias AwardsVoter.Context.Voting.Ballots.Ballot

  describe "Ballot.changeset/2" do
    test "should return errors if the voter is not provided" do
      cs = Ballot.changeset(%Ballot{}, %{voter: nil})
      errors = Ecto.Changeset.traverse_errors(cs, fn {msg, _opts} -> msg end)

      refute cs.valid?
      assert errors == %{voter: ["can't be blank"]}
    end

    test "should return changeset if params are valid" do
      cs = Ballot.changeset(%Ballot{}, %{voter: test_ballot().voter})

      assert cs.valid?
      assert %Ecto.Changeset{} = cs
    end

    test "should put the votes in using put_embed" do
      cs = Ballot.changeset(%Ballot{}, %{voter: test_ballot().voter, votes: test_ballot().votes})

      assert cs.valid?
      assert %Ecto.Changeset{} = cs
      assert Enum.all?(cs.changes.votes, fn v -> v.valid? end)
      cs_votes = cs.changes.votes |> Enum.map(fn v -> v.data end)
      assert cs_votes == test_ballot().votes
    end
  end

  describe "Ballot.save_ballot/2" do
    test "should return successful tuple if save was successful" do
      defmodule VoterSaveBallot do
        def save_ballot(_ballot, _show_name), do: :ok
      end
      Application.put_env(:awards_voter, :voter_mod, VoterSaveBallot)
      ballot = test_ballot()

      assert {:ok, ^ballot} = Ballot.save_ballot(ballot, test_show().name)
    end

    test "should return :error_saving if the save was unsuccessful" do
      defmodule InvalidVoterSaveBallot do
        def save_ballot(_ballot, _show_name), do: {:error, :reason}
      end
      Application.put_env(:awards_voter, :voter_mod, InvalidVoterSaveBallot)

      assert :error_saving = Ballot.save_ballot(test_ballot(), "Invalid Show Name")
    end
  end

  describe "Ballot.get_ballot_by_voter_and_show/2" do
    test "should return :not found if no ballot for voter found" do
      defmodule NotFoundVoterGet do
        def get_ballot_by_voter_and_show(_voter_name, _show_name), do: :not_found
      end
      Application.put_env(:awards_voter, :voter_mod, NotFoundVoterGet)

      assert :not_found = Ballot.get_ballot_by_voter_and_show("Invalid Voter Name", test_show().name)
    end

    test "should return success tuple if ballot found" do
      defmodule VoterModule do
        def get_ballot_by_voter_and_show(_voter_name, _show_name), do: test_ballot()
      end
      Application.put_env(:awards_voter, :voter_mod, VoterModule)
      ballot = test_ballot()

      assert {:ok, ^ballot} = Ballot.get_ballot_by_voter_and_show(test_ballot().voter, test_show().name)
    end

    test "should return :error_finding for all other errors" do
      defmodule ErrorVoterModule do
        def get_ballot_by_voter_and_show(_voter_name, _show_name), do: {:error, :reason}
      end
      Application.put_env(:awards_voter, :voter_mod, ErrorVoterModule)
      assert :error_finding = Ballot.get_ballot_by_voter_and_show(test_ballot().voter, test_show().name)
    end
  end
end
