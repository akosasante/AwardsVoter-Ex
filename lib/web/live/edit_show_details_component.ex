defmodule AwardsVoter.Web.EditShowDetails do
  use Phoenix.LiveComponent

  def render(assigns) do
    Phoenix.View.render(AwardsVoter.Web.AdminView, "edit_show_details.html", assigns)
  end
end
