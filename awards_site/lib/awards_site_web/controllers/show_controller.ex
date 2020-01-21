defmodule AwardsSiteWeb.ShowController do
  use AwardsSiteWeb, :controller

  alias AwardsSite.Admin
  alias AwardsSite.Show
  require Logger
  

  def index(conn, _params) do
    case Admin.list_shows() do
      [%Show{} | _] = shows -> render(conn, "index.html", shows: shows)
      e ->
        Logger.error("Error during Admin.list_show: #{inspect e}")
        conn
        |> put_flash(:error, "Could't fetch shows")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = Admin.change_show(%Show{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"show" => show_params}) do
    case Admin.create_show(show_params) do
      {:ok, show} ->
        conn
        |> put_flash(:info, "Show created successfully.")
        |> redirect(to: Routes.show_path(conn, :show, show.name))

      {:errors, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => name}) do
    case Admin.get_show!(name) do
      %Show{} = show -> render(conn, "show.html", show: show)
      e ->
        Logger.error("Error during Admin.get_show!: #{inspect e}")
        conn
        |> put_flash(:error, "Could't find show (#{name})")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def edit(conn, %{"id" => id}) do
    show = Admin.get_show!(id)
    changeset = Admin.change_show(show)
    render(conn, "edit.html", show: show, changeset: changeset)
  end

  def update(conn, %{"id" => id, "show" => show_params}) do
    show = Admin.get_show!(id)

    case Admin.update_show(show, show_params) do
      {:ok, show} ->
        conn
#        |> put_flash(:info, "Show updated successfully.")
        |> redirect(to: Routes.show_path(conn, :show, show))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", show: show, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => name}) do
    show = Admin.get_show!(name)
    {:ok, _show} = Admin.delete_show(show)

    conn
    |> put_flash(:info, "Show deleted successfully.")
    |> redirect(to: Routes.show_path(conn, :index))
  end
end
