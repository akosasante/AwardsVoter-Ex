defmodule AwardsVoter.Web.AdminContestantDetails do
  use Phoenix.LiveComponent

  def render(assigns) do
    AwardsVoter.Web.AdminView.render_view_page("contestant_details.html", assigns)
  end
end
