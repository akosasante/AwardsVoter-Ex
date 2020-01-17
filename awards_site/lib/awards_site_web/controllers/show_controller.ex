defmodule AwardsSiteWeb.ShowController do
  use AwardsSiteWeb, :controller

  alias AwardsSite.Admin
  alias AwardsSite.Show

  def index(conn, _params) do
    shows = Admin.list_shows()
    render(conn, "index.html", shows: shows)
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
        |> redirect(to: Routes.show_path(conn, :show, show))

      {:errors, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    show = Admin.get_show!(id)
    render(conn, "show.html", show: show)
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
        |> put_flash(:info, "Show updated successfully.")
        |> redirect(to: Routes.show_path(conn, :show, show))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", show: show, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    show = Admin.get_show!(id)
    {:ok, _show} = Admin.delete_show(show)

    conn
    |> put_flash(:info, "Show deleted successfully.")
    |> redirect(to: Routes.show_path(conn, :index))
  end
end
