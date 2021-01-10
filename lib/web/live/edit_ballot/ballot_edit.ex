defmodule AwardsVoter.Web.BallotEdit do
  use Phoenix.LiveView

  alias AwardsVoter.Context.Ballots
  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Web.Router.Helpers, as: Routes

  def render(assigns) do
    AwardsVoter.Web.BallotView.render("edit_ballot.html", assigns)
  end

  def mount(%{"id" => ballot_id}, _session, socket) do
    socket = assign_new(socket, :original_ballot, fn -> Ballots.get_ballot(ballot_id) end)
    socket = assign_new(socket, :vote_map, fn -> generate_vote_map(socket.assigns.original_ballot.votes) end)

    socket = assign_new(socket, :show, fn -> Admin.get_show_by_id(socket.assigns.original_ballot.show_id) end)

    {:ok,socket}
  end

  def handle_params(%{"current_category" => current_category_name}, _uri, %{assigns: %{show: show}} = socket) do
    current_category = Admin.get_category_by_name(show, current_category_name)
    socket = assign(socket, :current_category, current_category)
    {:noreply, socket}
  end

  def handle_params(_params, uri, %{assigns: %{next_category: next_category}} = socket) do
    {:noreply, push_patch(socket, to: "#{URI.parse(uri).path}?current_category=#{next_category.name}")}
  end

  def handle_params(_params, uri, %{assigns: %{show: show}} = socket) do
    first_category = show.categories |> List.first()

    {:noreply, push_patch(socket, to: "#{URI.parse(uri).path}?current_category=#{first_category.name}")}
  end

  def handle_event("update_vote", %{"vote" => vote}, %{assigns: %{current_category: category, vote_map: vote_map}} = socket) do
    voted_contestant = Map.get(vote, category.name)

    vote_map = Map.put(vote_map, category.name, voted_contestant)
    socket = assign(socket, :vote_map, vote_map)

    {:noreply, socket}
  end

  def handle_event("next_category", %{"category" => current_category_name}, %{assigns: %{show: show, original_ballot: original_ballot}} = socket) do
    index = Enum.find_index(show.categories, fn category -> category.name == current_category_name end)
    next_category = Enum.at(show.categories, rem(index + 1, length(show.categories)))

   {:noreply, push_patch(socket, to: Routes.live_path(socket, AwardsVoter.Web.BallotEdit, original_ballot.id, current_category: next_category.name))}
  end

  def handle_event("reset_vote", %{"category" => category_name_to_reset}, %{assigns: %{vote_map: vote_map}} = socket) do
    vote_map = Map.put(vote_map, category_name_to_reset, nil)
    socket = assign(socket, :vote_map, vote_map)

    {:noreply, socket}
  end

  def handle_event("submit_ballot", _, %{assigns: %{vote_map: vote_map, original_ballot: original_ballot, show: show}} = socket) do
    votes = vote_map_into_votes(vote_map, show)
    updated_ballot = Map.put(original_ballot, :votes, votes)

    :ok = Ballots.save_ballot(updated_ballot)

    {:noreply, push_redirect(socket, to: Routes.ballot_path(socket, :get_ballot, original_ballot.id))}
  end

  defp generate_vote_map(votes) do
    Enum.reduce(votes, %{}, fn vote, vote_map ->
      Map.put(vote_map, vote.category.name, vote.contestant.name)
    end)
  end

  defp vote_map_into_votes(vote_map, show) do
    Enum.map(vote_map, fn {category_name, contestant_name} ->
      category = Admin.get_category_by_name(show, category_name)
      contestant = Admin.get_contestant_by_name(category, contestant_name) |> Admin.contestant_to_map()
      Ballots.create_vote(%{category: category |> Admin.category_to_map(), contestant: contestant})
    end)
  end
end
