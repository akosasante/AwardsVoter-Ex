defmodule AwardsVoter.Web.BallotsSummary do
  use AwardsVoter.Web, :live_view

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Ballots
  alias AwardsVoter.Context.Models.Show

  def render(assigns) do
    AwardsVoter.Web.SummariesView.render("ballots_summary.html", assigns)
  end

  def mount(%{"id" => show_id}, _, socket) do
    AwardsVoter.Web.Endpoint.subscribe("show:#{show_id}")

    socket =
      socket
      |> assign_new(:show, fn -> Admin.get_show_by_id(show_id) end)
      |> assign_new(:ballots, fn -> Ballots.fetch_ballots_for_show(show_id) end)

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    current_ballot_id = Map.get(params, "current_ballot")
    socket = assign(socket, current_ballot_id: current_ballot_id)
    {:noreply, socket}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "winner_updated", payload: _map_with_category_and_contestant, topic: "show:" <> show_id}, socket) do
    %Show{} = show = Admin.get_show_by_id(show_id)
    socket = assign(socket, :show, show)
    {:noreply, socket}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "ballot_updated", payload: _map_with_updated_ballot, topic: "show:" <> show_id}, socket) do
    ballots = Ballots.fetch_ballots_for_show(show_id)
    socket = assign(socket, :ballots, ballots)
    {:noreply, socket}
  end
end
