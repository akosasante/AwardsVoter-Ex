defmodule AwardsVoter.Web.Scoreboard do
  use Phoenix.LiveView

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Ballots
  alias AwardsVoter.Context.Models.Show

  def render(assigns) do
    AwardsVoter.Web.SummariesView.render("scoreboard.html", assigns)
  end

  def mount(%{"id" => show_id}, _, socket) do
    %Show{} = show = Admin.get_show_by_id(show_id)

    socket =
      socket
      |> assign_new(:show, fn -> show end)
      |> assign_new(:ballots, fn -> Ballots.fetch_ballots_for_show(show_id) end)

    {:ok, socket}
  end
end
