defmodule AwardsVoter.Web.Scoreboard do
  use Phoenix.LiveView

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Ballots
  alias AwardsVoter.Context.Models.Show

  def render(assigns) do
    AwardsVoter.Web.SummariesView.render("scoreboard.html", assigns)
  end

  def mount(%{"id" => show_id}, _, socket) do
    AwardsVoter.Web.Endpoint.subscribe("show:#{show_id}")

    socket =
      socket
      |> assign_new(:show, fn -> Admin.get_show_by_id(show_id) end)
      |> assign_new(:ballots, fn ->
        Ballots.fetch_ballots_for_show(show_id)
        |> Enum.sort_by(fn ballot -> {AwardsVoter.Web.SummariesView.num_correct(ballot), AwardsVoter.Web.SummariesView.num_voted(ballot)} end, :desc)
      end)

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
      |> Enum.sort_by(fn ballot -> {AwardsVoter.Web.SummariesView.num_correct(ballot), AwardsVoter.Web.SummariesView.num_voted(ballot)} end, :desc)
    socket = assign(socket, :ballots, ballots)
    {:noreply, socket}
  end

  # TODO: maybe only update the bits that need updating? Can we get some animation happening?
  # TODO: Updating things when admin edits other parts of the show
  # Styliing, page transitions, interactivity
  # password protection, proper users
end
