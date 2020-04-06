defmodule AwardsVoter.Web.BallotControllerTest do
  use AwardsVoter.Web.ConnCase

  import Phoenix.LiveViewTest

  alias AwardsVoter.Context.Voting

  @moduletag :do_ballots_setup
  @moduletag :do_show_setup

  defp total_ballot_count(show_name) do
    Enum.count(Voting.list_ballots_for_show(show_name))
  end


  test "GET :continue renders form", %{conn: conn} do
    {:ok, show} = saved_test_show()

    conn = get(conn, Routes.ballot_path(conn, :continue, show.name))

    assert html_response(conn, 200) =~ "Continue existing ballot for #{show.name}"
  end

  test "GET :new renders blank form", %{conn: conn} do
    {:ok, show} = saved_test_show()

    conn = get(conn, Routes.ballot_path(conn, :new, show.name))

    assert html_response(conn, 200) =~ "New ballot for #{show.name}"
  end

  test "POST :validate_continue renders edit page if ballot exists", %{conn: conn} do
    {:ok, show} = saved_test_show()
    {:ok, _ballot} = saved_test_ballot()

    conn = post(conn, Routes.ballot_path(conn, :validate_continue, show.name), ballot: %{"username" => test_ballot().voter})

    assert html_response(conn, 200) =~ "<strong>#{test_ballot().voter}</strong> ballot for: <strong>#{show.name}</strong>"
  end

  test "POST :validate_continue redirects to continue ballot page if username not in use", %{conn: conn} do
    {:ok, show} = saved_test_show()
    show_name_uri = URI.encode(show.name)

    validate_conn = post(conn, Routes.ballot_path(conn, :validate_continue, show.name), ballot: %{"username" => "Fake Voter"})

        assert %{show_name: ^show_name_uri} = redirected_params(validate_conn)
        assert redirected_to(validate_conn) == Routes.ballot_path(conn, :continue, show.name)
        assert Voting.get_ballot_for("Fake Voter", show.name) == :not_found
  end

  test "GET :show displays details for selected ballot, redirects if not found", %{conn: conn} do
    {:ok, show} = saved_test_show()
    {:ok, ballot} = saved_test_ballot()

    conn = get(conn, Routes.ballot_path(conn, :show, show.name, ballot.voter))

    assert html_response(conn, 200) =~ ballot.voter
    for vote <- ballot.votes do
      assert conn.resp_body =~ vote.category.name
    end

    not_found_conn = get(conn, Routes.ballot_path(conn, :show, show.name, "Fake Name"))
    assert redirected_to(not_found_conn) == Routes.page_path(conn, :index)
  end

  test "POST :create should add a new ballot to show in table and redirect", %{conn: conn} do
    {:ok, show} = saved_test_show()
    {:ok, ballot} = saved_test_ballot()
    username = "new_voter"
    updated_ballot = %{ballot | voter: username}

    conn = post(conn, Routes.ballot_path(conn, :create, show.name), ballot: %{username: username})

    assert html_response(conn, 200) =~ "<strong>#{username}</strong> ballot for: <strong>#{show.name}</strong>"
    assert Voting.get_ballot_for(username, show.name) == {:ok, updated_ballot}
  end

  test "POST :create does not create ballot, redirects to :new page if username already exists", %{conn: conn} do
    {:ok, show} = saved_test_show()
    {:ok, ballot} = saved_test_ballot()
    count_before = total_ballot_count(show.name)
    show_name_uri = URI.encode(show.name)

    create_conn = post(conn, Routes.ballot_path(conn, :create, show.name), ballot: %{"username" => ballot.voter})

    assert %{show_name: ^show_name_uri} = redirected_params(create_conn)
    assert redirected_to(create_conn) == Routes.ballot_path(conn, :new, show.name)
    assert total_ballot_count(show.name) == count_before
  end

  test "PUT :update updates user ballot and redirects", %{conn: conn} do
    {:ok, show} = saved_test_show()
    {:ok, ballot} = saved_test_ballot()
    {vote_map, updated_ballot} = update_ballot_votes(ballot)


    conn = put(conn, Routes.ballot_path(conn, :update, show.name, ballot.voter), ballot: vote_map)

    assert html_response(conn, 200) =~ ballot.voter
    for vote <- ballot.votes do
      assert conn.resp_body =~ vote.category.name
      if vote.contestant, do: assert conn.resp_body =~ vote.contestant.name
    end

    assert Voting.get_ballot_for(ballot.voter, show.name) == {:ok, updated_ballot}
  end

  test "GET :scoreboard will initially render just the show name", %{conn: conn} do
    {:ok, show} = saved_test_show()
    {:ok, ballot} = saved_test_ballot()

    conn = get(conn, Routes.ballot_path(conn, :scoreboard, show.name))

    assert html_response(conn, 200) =~ "<h1>#{show.name}</h1>"
    assert conn.resp_body =~ "Username"
    assert conn.resp_body =~ "Total Correct Answers"
    assert conn.resp_body =~ "<td>#{ballot.voter}</td>"
    assert conn.resp_body =~ "<td>0</td>"
  end

  test "GET :scoreboard will update with scores", %{conn: conn} do
    {:ok, show} = saved_test_show()
    {:ok, ballot} = saved_test_ballot()
    {vote_map, _updated_ballot} = update_ballot_votes(ballot)

    {:ok, view, _html} = live(conn, Routes.ballot_path(conn, :scoreboard, show.name))

    _conn = put(conn, Routes.ballot_path(conn, :update, show.name, ballot.voter), ballot: vote_map)

    send(view.pid, %{event: "winner_updated", topic: "ballots:" <> show.name})
    assert render(view) =~ "<td>1</td>"
  end
end
