defmodule AwardsVoter.Web.BallotEdit do
  use Phoenix.LiveView

  alias AwardsVoter.Context.Ballots
  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Web.Router.Helpers, as: Routes

  def render(assigns) do
    AwardsVoter.Web.BallotView.render("edit_ballot.html", assigns)
  end

  def mount(%{"id" => ballot_id}, _session, socket) do
    socket =
      socket
      |> assign_new(:original_ballot, fn -> Ballots.get_ballot(ballot_id) end)

    socket = assign_new(socket, :show, fn -> Admin.get_show_by_id(socket.assigns.original_ballot.show_id) end)

    {:ok, socket}
  end
end