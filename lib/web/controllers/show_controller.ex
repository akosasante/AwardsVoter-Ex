defmodule AwardsVoter.Web.ShowController do
  use AwardsVoter.Web, :controller
  
  alias AwardsVoter.Context.Admin.Shows
  alias AwardsVoter.Context.Admin.Shows.Show
  
  require Logger
  
  def index(conn, _params) do
    case Shows.list_shows() do
      {:ok, shows} -> render(conn, "index.html", shows: shows, is_admin: true)
      e ->
        Logger.error("Error during Shows.list_show: #{inspect e}")
        conn
        |> put_flash(:error, "Could't fetch shows")
        |> redirect(to: Routes.show_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = Shows.change_show(%Show{})
    render(conn, "new.html", changeset: changeset, options: [], is_admin: true)
  end

  def create(conn, %{"show" => show_params}) do
    case Shows.create_show(show_params) do
      {:ok, show} ->
        conn
        |> put_flash(:info, "Show created successfully.")
        |> redirect(to: Routes.show_path(conn, :show, show_params["name"]))

      {:errors, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, options: [], is_admin: true)
    end
  end

  def show(conn, %{"name" => name}) do
    case Shows.get_show_by_name(name) do
      {:ok, show} -> render(conn, "show.html", show: show, is_admin: true)
      e ->
        Logger.error("Error during Shows.get_show_by_name: #{inspect e}")
        conn
        |> put_flash(:error, "Could't find show (#{name})")
        |> redirect(to: Routes.show_path(conn, :index))
    end
  end

  def edit(conn, %{"name" => name}) do
    show = Shows.get_show_by_name(name)
    changeset = Shows.change_show(show)
    render(conn, "edit.html", show: show, changeset: changeset, options: [method: "put"], is_admin: true)
  end

  def update(conn, %{"name" => name, "show" => show_params}) do
    show = Shows.get_show_by_name(name)

    case Shows.update_show(show, show_params) do
      {:ok, show} ->
        conn
        |> put_flash(:info, "Show updated successfully.")
        |> redirect(to: Routes.show_path(conn, :show, Shows.name))

      {:errors, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", show: show, changeset: changeset, options: [method: "put"], is_admin: true)
    end
  end

  def delete(conn, %{"name" => name}) do
    show = Shows.get_show_by_name(name)
    {:ok, _show} = Shows.delete_show(show)

    conn
    |> put_flash(:info, "Show deleted successfully.")
    |> redirect(to: Routes.show_path(conn, :index))
  end
end