defmodule AwardsVoter.Web.ShowController do
  use AwardsVoter.Web, :controller
  
  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Admin.Shows.Show
  
  require Logger
  
  def index(conn, _params) do
    case Admin.list_shows() do
      {:ok, shows} -> render(conn, "index.html", shows: shows)
      e ->
        Logger.error("Error during Admin.list_show: #{inspect e}")
        conn
        |> put_flash(:error, "Could't fetch shows")
        |> redirect(to: Routes.show_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = Admin.change_show(%Show{})
    render(conn, "new.html", changeset: changeset, options: [])
  end

  def create(conn, %{"show" => show_params}) do
    case Admin.create_show(show_params) do
      {:ok, show} ->
        conn
        |> put_flash(:info, "Show created successfully.")
        |> redirect(to: Routes.show_path(conn, :show, show.name))

      {:errors, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, options: [])
    end
  end

  def show(conn, %{"name" => name}) do
    case Admin.get_show_by_name(name) do
      {:ok, show} -> render(conn, "show.html", show: show)
      e ->
        Logger.error("Error during Admin.get_show_by_name: #{inspect e}")
        conn
        |> put_flash(:error, "Could't find show (#{name})")
        |> redirect(to: Routes.show_path(conn, :index))
    end
  end

  def edit(conn, %{"name" => name}) do
    {:ok, show} = Admin.get_show_by_name(name)
    changeset = Admin.change_show(show)
    render(conn, "edit.html", show: show, changeset: changeset, options: [method: "put"])
  end

  def update(conn, %{"name" => name, "show" => show_params}) do
    {:ok, show} = Admin.get_show_by_name(name)

    case Admin.update_show(show, show_params) do
      {:ok, show} ->
        conn
        |> put_flash(:info, "Show updated successfully.")
        |> redirect(to: Routes.show_path(conn, :show, show.name))

      {:errors, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", show: show, changeset: changeset, options: [method: "put"])
    end
  end

  def delete(conn, %{"name" => name}) do
    {:ok, show} = Admin.get_show_by_name(name)
    {:ok, _deleted_show} = Admin.delete_show(show)

    conn
    |> put_flash(:info, "Show deleted successfully.")
    |> redirect(to: Routes.show_path(conn, :index))
  end
end