defmodule AwardsVoter.Web.EditContestantDetails do
  use Phoenix.LiveComponent

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Models.Contestant

  def render(assigns) do
    AwardsVoter.Web.AdminView.render_edit_page("edit_contestant_details.html", assigns)
  end

  def update(
        %{show: show, category_name: category_name, contestant_name: contestant_name},
        socket
      ) do

    socket = case Admin.get_contestant_by_name(show, category_name, contestant_name) do
      nil -> socket
      selected_contestant -> assign_new(socket, :contestant_changeset, fn ->
        Contestant.to_changeset(selected_contestant)
      end)
    end

    {:ok, socket}
  end
end
