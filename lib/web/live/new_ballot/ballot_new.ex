defmodule AwardsVoter.Web.BallotNew do
  use Phoenix.LiveView

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Ballots
  alias AwardsVoter.Web.Router.Helpers, as: Routes

  def render(assigns) do
    AwardsVoter.Web.BallotView.render("new_ballot.html", assigns)
  end

  def mount(%{"show_id" => show_id}, _session, socket) do
    socket = assign_new(socket, :show, fn -> Admin.get_show_by_id(show_id) end)
    socket = assign_new(socket, :ballot_changeset, fn -> Ballots.new_ballot() end)
    {:ok, socket}
  end

  def handle_event("submit_new_ballot", %{"ballot_voter" => ballot_name, "userId" => user_id}, %{assigns: %{show: show}} = socket) do
    {ballot_type, ballot} = case Ballots.find_ballot_by_voter_and_show(user_id, show.id) do
      nil -> {:new, Ballots.create_ballot(%{"voter" => user_id, "show_id" => show.id, "ballot_name" => ballot_name})}
      ballot -> {:existing, ballot}
    end

    flash = case ballot_type do
      :new -> "Ballot created successfully."
      :existing -> "Existing ballot opened."
    end

    socket = socket
    |> put_flash(:info, flash)
    |> push_redirect(to: Routes.ballot_path(socket, :get_ballot, ballot.id))

    {:noreply, socket}
  end
end
