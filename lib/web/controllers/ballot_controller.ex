defmodule AwardsVoter.Web.BallotController do
  use AwardsVoter.Web, :controller

  alias AwardsVoter.Context.Ballots
  #    TODO: At some point we may need to replace this with a call that only gets active shows. What context would that live in?
  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Models.Show

  require Logger

  @buffer_airdate_duration 60 * 10 # users can still enter their votes up to 10 minutes after the starting time of the show

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
    within_airtime = airtime_is_valid(show)
    render(conn, :get_ballot, ballot: ballot, show: show, can_vote?: !read_only? and within_airtime)
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

  defp airtime_is_valid(%Show{air_datetime: nil}), do: true

  defp airtime_is_valid(%Show{air_datetime: air_datetime}) do
    {:ok, datetime, _utc_offset} = DateTime.from_iso8601(air_datetime <> ":00Z")
    {:ok, datetime_est} = DateTime.from_naive(datetime, "America/Toronto", Tz.TimeZoneDatabase)
    {:ok, now} = DateTime.now("America/Toronto", Tz.TimeZoneDatabase)
    DateTime.diff(now, datetime_est) <= @buffer_airdate_duration
  end
end
