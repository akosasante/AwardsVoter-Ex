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
      |> assign_new(:vote_map, fn -> Map.new() end)

    socket = assign_new(socket, :show, fn -> Admin.get_show_by_id(socket.assigns.original_ballot.show_id) end)

    {:ok,socket}
  end

  def handle_params(%{"current_category" => current_category_name}, _uri, %{assigns: %{show: show}} = socket) do
    current_category = Admin.get_category_by_name(show, current_category_name)
    socket = assign(socket, :current_category, current_category)
    {:noreply, socket}
  end

  def handle_params(_params, uri, %{assigns: %{show: show}} = socket) do
    first_category = socket.assigns.show.categories |> List.first()

    {:noreply, push_patch(socket, to: "#{URI.parse(uri).path}?current_category=#{first_category.name}")}
  end

  def handle_event("update_vote", %{"vote" => vote}, %{assigns: %{current_category: category, vote_map: vote_map}} = socket) do
    voted_contestant = Map.get(vote, category.name)
    contestant = Admin.get_contestant_by_name(category, voted_contestant)

    vote_map = Map.put(vote_map, category.name, voted_contestant)
    socket = assign(socket, :vote_map, vote_map)

    {:noreply, socket}
  end

  def handle_event("reset_vote", %{"category" => category_name_to_reset}, %{assigns: %{vote_map: vote_map}} = socket) do
    vote_map = Map.put(vote_map, category_name_to_reset, nil)
    socket = assign(socket, :vote_map, vote_map)

    {:noreply, socket}
  end
end
