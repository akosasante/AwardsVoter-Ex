defmodule AwardsVoter.Web.EditContestantDetails do
  use Phoenix.LiveComponent

  def render(assigns) do
    Phoenix.View.render(AwardsVoter.Web.AdminView, "edit_contestant_details.html", assigns)
  end
end
