defmodule AwardsVoter.Web.Scoreboard do
  use AwardsVoter.Web, :live_view

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Ballots
  alias AwardsVoter.Context.Models.Show

  @buffer_airdate_duration 60 * 10 # users can still enter their votes up to 10 minutes after the starting time of the show

  def render(assigns) do
    AwardsVoter.Web.SummariesView.render("scoreboard.html", assigns)
  end

  def mount(%{"id" => show_id}, _, socket) do
    AwardsVoter.Web.Endpoint.subscribe("show:#{show_id}")


    socket = assign_new(socket, :show, fn -> Admin.get_show_by_id(show_id) end)
    socket = assign_new(socket, :ballots, fn ->
        Ballots.fetch_ballots_for_show(show_id)
        |> Enum.sort_by(fn ballot -> {AwardsVoter.Web.SummariesView.num_correct(ballot, socket.assigns.show), AwardsVoter.Web.SummariesView.num_voted(ballot)} end, :desc)
      end)

    socket = assign(socket, :show_view_ballot, is_nil(socket.assigns.show.air_datetime) or !airtime_is_valid(socket.assigns.show))

    {:ok, socket}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "winner_updated", payload: _map_with_category_and_contestant, topic: "show:" <> show_id}, socket) do
    %Show{} = show = Admin.get_show_by_id(show_id)
    socket = assign(socket, :show, show)
    {:noreply, socket}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "ballot_updated", payload: _map_with_updated_ballot, topic: "show:" <> show_id}, socket) do
    ballots =
      Ballots.fetch_ballots_for_show(show_id)
      |> Enum.sort_by(fn ballot -> {AwardsVoter.Web.SummariesView.num_correct(ballot, socket.assigns.show), AwardsVoter.Web.SummariesView.num_voted(ballot)} end, :desc)
    socket = assign(socket, :ballots, ballots)
    {:noreply, socket}
  end

  defp airtime_is_valid(%Show{air_datetime: air_datetime}) do
    {:ok, datetime, _utc_offset} = DateTime.from_iso8601(air_datetime <> ":00Z")
    {:ok, datetime_est} = DateTime.from_naive(datetime, "America/Toronto", Tz.TimeZoneDatabase)
    {:ok, now} = DateTime.now("America/Toronto", Tz.TimeZoneDatabase)
    DateTime.diff(now, datetime_est) <= @buffer_airdate_duration
  end
end
