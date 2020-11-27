defmodule AwardsVoter.Web.AdminCategoryDetails do
  use Phoenix.LiveComponent

  def render(%{category: category} = assigns) do
    IO.puts "RENDERING CATEGORY LEEX: #{inspect category.name}"
    Phoenix.View.render(AwardsVoter.Web.AdminView, "category_details.html", assigns)
  end

end
