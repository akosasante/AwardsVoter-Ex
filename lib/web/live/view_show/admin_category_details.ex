defmodule AwardsVoter.Web.AdminCategoryDetails do
  use Phoenix.LiveComponent

  def render(%{category: _category} = assigns) do
    AwardsVoter.Web.AdminView.render_view_page("category_details.html", assigns)
  end

end
