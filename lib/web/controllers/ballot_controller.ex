defmodule AwardsVoter.Web.BallotController do
  use AwardsVoter.Web, :controller

  alias AwardsVoter.Context.Ballots
  #    TODO: At some point we may need to replace this with a call that only gets active shows. What context would that live in?
  alias AwardsVoter.Context.Admin

  require Logger

  def home(conn, _params) do
    case Admin.get_all_shows() do
      shows when is_list(shows) ->
        render(conn, :home_page, shows: shows)

      e ->
        Logger.error("Error during Admin.get_all_shows: #{inspect e}")

        conn
        |> put_flash(:error, "Couldn't fetch shows")
        |> redirect(to: "/")
    end
  end

  def get_ballot(conn, %{"id" => id}) do
    ballot = Ballots.get_ballot(id)
    show = Admin.get_show_by_id(ballot.show_id)
    render(conn, :get_ballot, ballot: ballot, show: show)
  end

  def new_ballot(conn, %{"show_id" => show_id}) do
    show = Admin.get_show_by_id(show_id)
    ballot = Ballots.new_ballot()
    render(conn, :new_ballot, ballot_changeset: ballot, show: show)
  end

  def create_ballot(conn, %{"ballot" => ballot_map}) do
    ballot = Ballots.save_ballot(ballot_map)

    conn
    |> put_flash(:info, "Ballot created successfully.")
    |> redirect(to: Routes.ballot_path(conn, :get_ballot, ballot.id))
  end

  def edit_ballot(conn, %{"id" => id}) do
    ballot = Ballots.get_ballot(id)
    show = Admin.get_show_by_id(ballot.show_id)
    # gett show for ballot.show_id
    # html is gonna list showw.catgoriees to give yoou a thing to click on to
    # by default start at the firsst cateegory
    # could be a live page so that we can kepp ballot in state without refrshing
    # save button savss whol ballot
    # keep in state an array of votes
    render(conn, :edit_ballot, show: show, ballot: ballot)
  end
end
