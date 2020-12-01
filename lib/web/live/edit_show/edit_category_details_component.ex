defmodule AwardsVoter.Web.EditCategoryDetails do
  use Phoenix.LiveComponent

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Models.Category

  def render(assigns) do
    AwardsVoter.Web.AdminView.render_edit_page("edit_category_details.html", assigns)
  end

  def update(%{show: show, category_name: category_name}, socket) do
    selected_category = Admin.get_category_by_name(show, category_name)

    socket =
      assign_new(socket, :category_changeset, fn -> Category.to_changeset(selected_category) end)

    {:ok, socket}
  end
end
