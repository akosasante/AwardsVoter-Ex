defmodule AwardsVoter.Web.AdminShowEdit do
  use Phoenix.LiveView

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Models.Show

  def render(assigns) do
    Phoenix.View.render(AwardsVoter.Web.AdminView, "show_edit.html", assigns)
  end

  def mount(params, %{"show_id" => show_id}, socket) do
    socket =
      assign_new(socket, :show, fn ->
        case Admin.get_show_by_id(show_id) do
          %Show{} = show -> show
          e -> nil
        end
      end)
      |> assign_new(:show_modal, fn -> false end)
    {:ok, socket}
  end
end
