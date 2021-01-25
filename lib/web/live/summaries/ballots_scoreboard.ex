defmodule AwardsVoter.Web.Scoreboard do
  use Phoenix.LiveView

  def render(assigns) do
    AwardsVoter.Web.SummariesView.render("scoreboard.html", assigns)
  end

  def mount(_, _, socket) do
    {:ok, socket}
  end
end
