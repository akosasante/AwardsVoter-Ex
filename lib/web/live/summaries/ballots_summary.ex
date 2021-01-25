defmodule AwardsVoter.Web.BallotsSummary do
  use Phoenix.LiveView

  def render(assigns) do
    AwardsVoter.Web.SummariesView.render("ballots_summary.html", assigns)
  end

  def mount(_, _, socket) do
    {:ok, socket}
  end
end
