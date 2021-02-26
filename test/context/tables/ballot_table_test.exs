defmodule AwardsVoter.Context.Tables.BallotTableTest do
  use AwardsVoter.DataCase, async: true

  alias AwardsVoter.Context.Tables.BallotTable

  setup do
    ballot_table_name = Application.get_env(:awards_voter, :ballot_table_name)
    {:ok, _} = :dets.open_file(ballot_table_name, file: './#{ballot_table_name}.dets')
    :ok = :dets.delete_all_objects(ballot_table_name)

    {:ok, _} =
      start_supervised({AwardsVoter.Context.Tables.BallotTable, [download_backups: false]})

    on_exit(fn ->
      #      IO.puts("Test complete. Cleaning up...")
      :dets.close(ballot_table_name)
    end)

    :ok
  end

  test "all/0 should return all the ballots in the table" do
    ballot = build(:ballot)
    assert [] == BallotTable.all()
    BallotTable.save([{ballot.id, ballot}])
    assert [ballot] == BallotTable.all()
  end

  test "all_ballots_for_voter/1 should return empty list if no objects in table with matching voter" do
    ballot = build(:ballot)
    BallotTable.save([{ballot.id, ballot}])
    assert [] == BallotTable.all_ballots_for_voter("Some random ballot voter")
  end

  test "all_ballots_for_voter/1 should return all the ballots in the table with matching voter" do
    ballot = build(:ballot)
    assert [] == BallotTable.all_ballots_for_voter(ballot.voter)
    BallotTable.save([{ballot.id, ballot}])
    assert [ballot] == BallotTable.all_ballots_for_voter(ballot.voter)
  end

  test "all_ballots_for_show/1 should return empty list if no objects in table with matching show id" do
    ballot = build(:ballot)
    BallotTable.save([{ballot.id, ballot}])
    assert [] == BallotTable.all_ballots_for_show("Some random show id")
  end

  test "all_ballots_for_show/1 should return all the ballots in the table with matching show id" do
    ballot = build(:ballot)
    assert [] == BallotTable.all_ballots_for_show(ballot.show_id)
    BallotTable.save([{ballot.id, ballot}])
    assert [ballot] == BallotTable.all_ballots_for_show(ballot.show_id)
  end

  test "get_by_id/1 should return :not_found if ballot not found in table" do
    assert :not_found == BallotTable.get_by_id("some-random-key")
  end

  test "get_by_id/1 should return a ballot if found in the table" do
    ballot = build(:ballot)
    assert :not_found == BallotTable.get_by_id(ballot.id)
    BallotTable.save([{ballot.id, ballot}])
    assert ballot == BallotTable.get_by_id(ballot.id)
  end

  test "get_by_voter_and_show/2 should return :not_found if ballot not found in table with matching voter and show" do
    assert :not_found ==
             BallotTable.get_by_voter_and_show("some-random-voter", "some-random-show")
  end

  test "get_by_voter_and_show/2 should return a ballot if found in the table with matching voter and show" do
    ballot = build(:ballot)
    assert :not_found == BallotTable.get_by_voter_and_show(ballot.voter, ballot.show_id)
    BallotTable.save([{ballot.id, ballot}])
    assert ballot == BallotTable.get_by_voter_and_show(ballot.voter, ballot.show_id)
  end

  test "save/1 should insert and return new ballot if not already in table" do
    ballot = build(:ballot)

    assert :ok = BallotTable.save([{ballot.id, ballot}])
    assert [ballot] == BallotTable.all()
  end

  test "save/1 should insert/update in dets based on ballot id already existing" do
    ballot_1 = build(:ballot)
    :ok = BallotTable.save([{ballot_1.id, ballot_1}])
    assert [ballot_1] == BallotTable.all()

    ballot_2 = build(:ballot)
    new_ballot = %{ballot_1 | voter: "Updated ballot voter", votes: []}

    assert ballot_1.id == new_ballot.id
    assert :ok = BallotTable.save([{new_ballot.id, new_ballot}, {ballot_2.id, ballot_2}])
    assert [new_ballot, ballot_2] == BallotTable.all()
  end

  test "delete/1 should return :ok if it successfully deleted ballot from table" do
    ballot = build(:ballot)
    :ok = BallotTable.save([{ballot.id, ballot}])
    assert [ballot] == BallotTable.all()

    assert :ok = BallotTable.delete(ballot.id)
    assert [] == BallotTable.all()
  end
end
