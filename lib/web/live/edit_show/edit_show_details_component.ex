defmodule AwardsVoter.Web.EditShowDetails do
  use Phoenix.LiveComponent

  alias AwardsVoter.Context.Models.Show

  def render(assigns) do
    AwardsVoter.Web.AdminView.render_edit_page("edit_show_details.html", assigns)
  end

  def update(%{show: show}, socket) do
    socket = assign_new(socket, :show_changeset, fn -> Show.to_changeset(show) end)
    {:ok, socket}
  end
end
