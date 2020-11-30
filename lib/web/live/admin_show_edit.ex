defmodule AwardsVoter.Web.AdminShowEdit do
  use Phoenix.LiveView

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Models.Show
  alias AwardsVoter.Context.Models.Category
  alias AwardsVoter.Context.Models.Contestant

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
      |> assign_new(:show_changeset, fn -> Show.to_changeset(Admin.get_show_by_id(show_id)) end)
      |> assign_new(:show_category, fn -> false end)
      |> assign_new(:category_changeset, fn -> nil end)
      |> assign_new(:contestant_changeset, fn -> nil end)
      |> assign_new(:show_contestant, fn -> false end)
    {:ok, socket}
  end

  def handle_event("save_show_details", %{"show" => show}, %{assigns: %{show_changeset: show_changeset}} = socket) do
    # TODO
    cs = Show.changeset(show_changeset, show) |> IO.inspect
    {:noreply, socket}
  end

  def handle_event("save_category_details", %{"category" => category}, %{assigns: %{category_changeset: category_changeset}} = socket) do
    # TODO
    cs = Category.changeset(category_changeset, category) |> IO.inspect
    {:noreply, socket}
  end

  def handle_event("show_category", %{"category" => category_name}, %{assigns: %{show: show}} = socket) do
    socket =
      if socket.assigns.show_category and socket.assigns.category_changeset.data.name == category_name do
        socket
        |> assign(:category_changeset, nil)
        |> assign(:show_category, false)
      else
        category = Enum.find(show.categories, fn cat -> cat.name == category_name end)
        cs = Category.to_changeset(category)
        socket
        |> assign(:category_changeset, cs)
        |> assign(:show_category, true)
      end

    {:noreply, socket}
  end

  def handle_event("show_contestant", %{"contestant" => contestant_name}, %{assigns: %{show: show, category_changeset: category_changeset}} = socket) do
    socket =
      if socket.assigns.show_contestant and socket.assigns.contestant_changeset.data.name == contestant_name do
        socket
        |> assign(:contestant_changeset, nil)
        |> assign(:show_contestant, false)
      else
        category = Ecto.Changeset.apply_changes(category_changeset)
        contestant = Enum.find(category.contestants, fn cont -> cont.name == contestant_name end)
        cs = Contestant.to_changeset(contestant)
        socket
        |> assign(:contestant_changeset, cs)
        |> assign(:show_contestant, true)
      end

    {:noreply, socket}
  end
end
