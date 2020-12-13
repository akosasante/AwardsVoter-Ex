defmodule AwardsVoter.Web.BallotController do
  use AwardsVoter.Web, :controller

  alias AwardsVoter.Context.Ballots

  require Logger

  def get_ballot(conn, %{"id" => id}) do
    render(conn, :get_ballot, ballot: id)
  end

  def new_ballot(conn, %{"show_id" => show_id}) do
    ballot = Ballots.new_ballot()
    render(conn, :new_ballot, ballot_changeset: ballot, show_id: show_id)
  end

  def create_ballot(conn, %{"ballot" => ballot_map}) do
    ballot = Ballots.save_ballot(ballot_map)

    conn
    |> put_flash(:info, "Ballot created successfully.")
    |> redirect(to: Routes.ballot_path(conn, :get_ballot, ballot.id))
  end
end
