defmodule AwardsVoter.Web.EditCategoryDetails do
  use Phoenix.LiveComponent

  def render(assigns) do
    Phoenix.View.render(AwardsVoter.Web.AdminView, "edit_category_details.html", assigns)
  end
end
