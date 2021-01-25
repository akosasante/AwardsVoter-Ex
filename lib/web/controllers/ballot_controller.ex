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

  def get_ballot(conn, %{"id" => id} = params) do
    read_only? = Map.get(params, "read_only") == "true"
    ballot = Ballots.get_ballot(id)
    show = Admin.get_show_by_id(ballot.show_id)
    render(conn, :get_ballot, ballot: ballot, show: show, can_vote?: !read_only?)
  end

  def new_ballot(conn, %{"show_id" => show_id}) do
    show = Admin.get_show_by_id(show_id)
    ballot = Ballots.new_ballot()
    render(conn, :new_ballot, ballot_changeset: ballot, show: show)
  end

  def create_or_update_ballot(conn, %{"ballot" => %{"voter" => voter, "show_id" => show_id} = ballot_map}) do
    {ballot_type, ballot} = case Ballots.find_ballot_by_voter_and_show(voter, show_id) do
      nil -> {:new, Ballots.create_ballot(ballot_map)}
      ballot -> {:existing, ballot}
    end

    flash = case ballot_type do
      :new -> "Ballot created successfully."
      :existing -> "Existing ballot opened."
    end

    conn
    |> put_flash(:info, flash)
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
