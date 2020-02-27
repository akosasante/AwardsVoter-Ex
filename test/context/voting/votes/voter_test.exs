defmodule AwardsVoter.Context.Voting.Votes.VoterTest do
  use AwardsVoter.DataCase

  alias AwardsVoter.Context.Voting.Votes.Voter

  @ballot_table Application.get_env(:awards_voter, :voter_ballots_table)
  @moduletag :do_ballots_setup

  describe "Voter server callbacks" do
    test "handle_call {:upsert_ballot, ballot, show_name} should insert a new ballot for a given show and voter" do
      assert {:reply, :ok, _state} = Voter.handle_call({:upsert_ballot, test_ballot(), test_show().name}, :pid, :ballot_table)
      table_key = {test_show().name, test_ballot().voter}
      assert :dets.lookup(@ballot_table, table_key) == [{table_key, test_ballot()}]
    end
    test "handle_call {:upsert_ballot, ballot, show_name}should update an existing ballot if show name AND voter name match" do
      table_key = {test_show().name, test_ballot().voter}
      :dets.insert(@ballot_table, {table_key, test_ballot()})

      {_, updated_ballot} = update_ballot_votes(test_ballot())

      assert {:reply, :ok, _state} = Voter.handle_call({:upsert_ballot, updated_ballot, test_show().name}, :pid, :ballot_table)
      refute :dets.lookup(@ballot_table, table_key) == [{table_key, test_ballot()}]
      assert :dets.lookup(@ballot_table, table_key) == [{table_key, updated_ballot}]
    end

    test "handle_call {:get_ballot, voter, show} should return :not_found if a matching ballot not found" do
      assert {:reply, :not_found, _state} = Voter.handle_call({:get_ballot, test_ballot().voter, test_show().name}, :pid, :ballot_table)
    end
    test "handle_call {:get_ballot, voter, show} should return a ballot if matching key found" do
      ballot = test_ballot()
      table_key = {test_show().name, ballot.voter}
      :dets.insert(@ballot_table, {table_key, ballot})

      assert {:reply, ^ballot, _state} = Voter.handle_call({:get_ballot, test_ballot().voter, test_show().name}, :pid, :ballot_table)
    end

    test "handle_call {:list_voter_ballots, voter} should return a list of all the ballots for various shows for a given voter" do
      ballot = test_ballot()
      other_ballot = test_ballot("Other Voter")
      :ok = 1..5
       |> Enum.map(fn num -> {"Test Show #{num}", ballot.voter} end)
       |> Enum.each(fn key -> :dets.insert(@ballot_table, {key, ballot}) end)
      :dets.insert(@ballot_table, {{test_show().name, other_ballot.voter}, other_ballot})

      {:reply, res, _state} = Voter.handle_call({:list_voter_ballots, ballot.voter}, :pid, :ballot_table)
      assert res == 1..5 |> Enum.map(fn _ -> ballot end)
      assert Enum.count(res) == 5
      refute Enum.find(res, fn b -> b.voter == other_ballot.voter end)
    end
    test "handle_call {:list_voter_ballots, voter} should return an empty list if no matching ballots found" do
      {:reply, [], _state} = Voter.handle_call({:list_voter_ballots, test_ballot().voter}, :pid, :ballot_table)
    end

    test "handle_call {:list_show_ballots, show} should return a list of all the ballots for various voters for a given show" do
      ballot = test_ballot()
      other_ballot = test_ballot("Other Voter")
      :ok = 1..5
        |> Enum.map(fn num -> {test_show().name, "Voter ##{num}"} end)
        |> Enum.each(fn key -> :dets.insert(@ballot_table, {key, ballot}) end)
      :dets.insert(@ballot_table, {{"Some other show", other_ballot.voter}, other_ballot})

      {:reply, res, _state} = Voter.handle_call({:list_show_ballots, test_show().name}, :pid, :ballot_table)
      assert res == 1..5 |> Enum.map(fn _ -> ballot end)
      assert Enum.count(res) == 5
      refute Enum.find(res, fn b -> b.voter == other_ballot.voter end)
    end
    test "handle_call {:list_show_ballots, show} should return an empty list if no matching ballots found" do
      {:reply, [], _state} = Voter.handle_call({:list_show_ballots, test_show().name}, :pid, :ballot_table)
    end
  end
end