defmodule AwardsVoter.Web.AdminShowEdit do
  use AwardsVoter.Web, :live_view

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Models.Show
  alias AwardsVoter.Web.Router.Helpers, as: Routes

  def render(assigns) do
    AwardsVoter.Web.AdminView.render_edit_page("show_edit.html", assigns)
  end

  def mount(%{"id" => show_id}, _session, socket) do
    %Show{} = show = Admin.get_show_by_id(show_id)

    socket =
      socket
      |> assign_new(:original_show, fn -> show end)
      |> assign_new(:updated_show, fn -> show end)
      |> assign_new(:show_category, fn -> false end)
      |> assign_new(:selected_category_name, fn -> nil end)
      |> assign_new(:show_contestant, fn -> false end)
      |> assign_new(:selected_contestant_name, fn -> nil end)

    {:ok, socket}
  end

  def handle_event(
        "save_show_details",
        %{"show" => show},
        %{assigns: %{updated_show: updated_show}} = socket
      ) do
    {:ok, new_show} = Show.update(updated_show, show)
    socket = assign(socket, :updated_show, new_show)
    {:noreply, socket}
  end

  def handle_event(
        "save_category_details",
        %{"category" => updated_category_map},
        %{assigns: %{selected_category_name: selected_category_name, updated_show: updated_show}} =
          socket
      ) do
    original_category = Admin.get_category_by_name(updated_show, selected_category_name)
    new_show = Admin.update_show_category(updated_show, original_category, updated_category_map)

    socket =
      socket
      |> assign(:updated_show, new_show)
      |> assign(:selected_category_name, updated_category_map["name"])

    {:noreply, socket}
  end

  def handle_event(
        "save_contestant_details",
        %{"contestant" => updated_contestant_map},
        %{
          assigns: %{
            selected_contestant_name: selected_contestant_name,
            selected_category_name: selected_category_name,
            updated_show: updated_show
          }
        } = socket
      ) do
    original_contestant =
      Admin.get_contestant_by_name(updated_show, selected_category_name, selected_contestant_name)

    new_show =
      Admin.update_show_contestant(
        updated_show,
        selected_category_name,
        original_contestant,
        updated_contestant_map
      )

    socket =
      socket
      |> assign(:updated_show, new_show)
      |> assign(:selected_contestant_name, updated_contestant_map["name"])

    {:noreply, socket}
  end

  def handle_event("show_category", %{"category" => category_name}, socket) do
    socket =
      if socket.assigns.show_category and socket.assigns.selected_category_name == category_name do
        socket
        |> assign(:selected_category_name, nil)
        |> assign(:show_category, false)
      else
        socket
        |> assign(:selected_category_name, category_name)
        |> assign(:show_category, true)
      end

    {:noreply, socket}
  end

  def handle_event("show_contestant", %{"contestant" => contestant_name}, socket) do
    socket =
      if socket.assigns.show_contestant and
           socket.assigns.selected_contestant_name == contestant_name do
        socket
        |> assign(:contestant_changeset, nil)
        |> assign(:show_contestant, false)
      else
        socket
        |> assign(:selected_contestant_name, contestant_name)
        |> assign(:show_contestant, true)
      end

    {:noreply, socket}
  end

  def handle_event(
        "delete_category",
        %{"category" => category_name},
        %{assigns: %{updated_show: show}} = socket
      ) do
    new_show = Admin.remove_category_from_show(show, category_name)

    socket =
      if socket.assigns.show_category and socket.assigns.selected_category_name == category_name do
        socket
        |> assign(:selected_category_name, nil)
        |> assign(:show_category, false)
      else
        socket
      end
      |> assign(:updated_show, new_show)

    {:noreply, socket}
  end

  def handle_event(
        "delete_contestant",
        %{"contestant" => contestant_name},
        %{assigns: %{updated_show: show, selected_category_name: selected_category_name}} = socket
      ) do
    new_show = Admin.remove_contestant_from_show(show, selected_category_name, contestant_name)

    socket =
      if socket.assigns.show_contestant and
           socket.assigns.selected_contestant_name == contestant_name do
        socket
        |> assign(:selected_contestant_name, nil)
        |> assign(:show_contestant, false)
      else
        socket
      end
      |> assign(:updated_show, new_show)

    {:noreply, socket}
  end

  def handle_event("submit_save", _params, %{assigns: %{updated_show: show}} = socket) do
    :ok = Admin.save_show(show)
    {:noreply, push_redirect(socket, to: Routes.admin_path(socket, :get_show, show))}
  end
end
