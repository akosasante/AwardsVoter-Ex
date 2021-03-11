defmodule AwardsVoter.Web.BallotCompare do
  use AwardsVoter.Web, :live_view

  alias AwardsVoter.Context.Ballots
  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Models.Show

  def render(assigns) do
    AwardsVoter.Web.BallotView.render("compare_ballots.html", assigns)
  end

  def mount(%{"first_ballot" => ballot_1_id, "second_ballot" => ballot_2_id}, _session, socket) do

    socket =
      socket
      |> assign_new(:ballot1, fn -> Ballots.get_ballot(ballot_1_id) end)
      |> assign_new(:ballot2, fn -> Ballots.get_ballot(ballot_2_id) end)

    socket = assign_new(socket, :show, fn -> Admin.get_show_by_id(socket.assigns.ballot1.show_id) end)

    AwardsVoter.Web.Endpoint.subscribe("show:#{socket.assigns.ballot1.show_id}")

    {:ok, socket}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "winner_updated", payload: _map_with_category_and_contestant, topic: "show:" <> show_id}, socket) do
    %Show{} = show = Admin.get_show_by_id(show_id)
    socket = assign(socket, :show, show)
    {:noreply, socket}
  end
end
