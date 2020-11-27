defmodule AwardsVoter.Web.AdminShowDetails do
  use Phoenix.LiveView

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Models.Show

  def render(assigns) do
#    IO.puts "RENDERING SHOW LEEX"
    Phoenix.View.render(AwardsVoter.Web.AdminView, "show_details.html", assigns)
  end

  def mount(params, %{"show_id" => show_id}, socket) do
#    IO.puts "MOUNTING SHOW"
    socket = assign_new(socket, :show, fn ->
      case Admin.get_show_by_id(show_id) do
        %Show{} = show -> show
        e -> nil
      end
    end)
    |> assign_new(:show_modal, fn -> false end)
    {:ok, socket}
  end

  def handle_event("show_modal", %{"show_modal_type" => type, "show_modal_content" => value}, socket) do
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
end
