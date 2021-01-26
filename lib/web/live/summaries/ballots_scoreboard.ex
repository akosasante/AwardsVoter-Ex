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
      |> assign_new(:ballots, fn -> Ballots.fetch_ballots_for_show(show_id) end)

    {:ok, socket}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "winner_updated", payload: _map_with_category_and_contestant, topic: "show:" <> show_id}, socket) do
    %Show{} = show = Admin.get_show_by_id(show_id)
    socket = assign(socket, :show, show)
    {:noreply, socket}
  end
end
