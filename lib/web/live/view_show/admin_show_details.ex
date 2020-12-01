defmodule AwardsVoter.Web.AdminShowDetails do
  use Phoenix.LiveView

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Models.Show

  def render(assigns) do
    AwardsVoter.Web.AdminView.render_view_page("show_details.html", assigns)
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

  def handle_event(
        "show_modal",
        %{"show_modal_type" => type, "show_modal_content" => value},
        socket
      ) do
    socket =
      socket
      |> assign(:show_modal, true)
      |> assign(:show_modal_type, type)
      |> assign(:show_modal_content, value)

    {:noreply, socket}
  end

  def handle_event("close_modal", _params, socket) do
    socket = assign(socket, :show_modal, false)
    {:noreply, socket}
  end

  def handle_event(
        "set_as_winner",
        %{"category_name" => category_name, "contestant_name" => contestant_name},
        %{assigns: %{show: show}} = socket
      ) do
    :ok =
      Admin.set_category_winner(show, category_name, contestant_name)
      |> Admin.save_show()

    updated_show = Admin.get_show_by_id(show.id)
    socket = assign(socket, :show, updated_show)
    {:noreply, socket}
  end
end
