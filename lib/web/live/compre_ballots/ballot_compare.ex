defmodule AwardsVoter.Web.BallotCompare do
  use AwardsVoter.Web, :live_view

  alias AwardsVoter.Context.Ballots
  alias AwardsVoter.Context.Admin

  def render(assigns) do
    AwardsVoter.Web.BallotView.render("compare_ballots.html", assigns)
  end

  def mount(%{"first_ballot" => ballot_1_id, "second_ballot" => ballot_2_id}, _session, socket) do
    socket =
      socket
      |> assign_new(:ballot1, fn -> Ballots.get_ballot(ballot_1_id) end)
      |> assign_new(:ballot2, fn -> Ballots.get_ballot(ballot_2_id) end)

    socket = assign_new(socket, :show, fn -> Admin.get_show_by_id(socket.assigns.ballot1.show_id) end)

    {:ok, socket}
  end
end
