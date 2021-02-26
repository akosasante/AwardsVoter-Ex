defmodule AwardsVoter.Web.BallotNew do
  use Phoenix.LiveView

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Ballots

  def render(assigns) do
    AwardsVoter.Web.BallotView.render("new_ballot.html", assigns)
  end

  def mount(%{"show_id" => show_id}, _session, socket) do
    socket = assign_new(socket, :show, fn -> Admin.get_show_by_id(show_id) end)
    socket = assign_new(socket, :ballot_changeset, fn -> Ballots.new_ballot() end)
    {:ok, socket}
  end

  def handle_event("submit_new_ballot", %{"ballot_voter" => ballot_name, "userId" => userId}, socket) do
    IO.inspect(userCredential, label: :userCredential)
    socket
  end
end
