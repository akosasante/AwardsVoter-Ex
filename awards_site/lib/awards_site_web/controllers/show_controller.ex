defmodule AwardsSiteWeb.ShowController do
  use AwardsSiteWeb, :controller

  alias AwardsSite.Admin.Shows
  alias AwardsSite.Admin.Shows.Show
  require Logger
  

  def index(conn, _params) do
    case Shows.list_shows() do
      [%Show{} | _] = shows -> render(conn, "index.html", shows: shows)
      e ->
        Logger.error("Error during Shows.list_show: #{inspect e}")
        conn
        |> put_flash(:error, "Could't fetch shows")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = Shows.change_show(%Show{})
    render(conn, "new.html", changeset: changeset, options: [])
  end

  def create(conn, %{"show" => show_params}) do
    case Shows.create_show(show_params) do
      {:ok, show} ->
        conn
        |> put_flash(:info, "Show created successfully.")
        |> redirect(to: Routes.show_path(conn, :show, Shows.name))

      {:errors, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, options: [])
    end
  end

  def show(conn, %{"id" => name}) do
    case Shows.get_show!(name) do
      %Show{} = show -> render(conn, "Shows.html", show: show)
      e ->
        Logger.error("Error during Shows.get_show!: #{inspect e}")
        conn
        |> put_flash(:error, "Could't find show (#{name})")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def edit(conn, %{"id" => name}) do
    show = Shows.get_show!(name)
    changeset = Shows.change_show(show)
    render(conn, "edit.html", show: show, changeset: changeset, options: [method: "put"])
  end

  def update(conn, %{"id" => name, "show" => show_params}) do
    show = Shows.get_show!(name)

    case Shows.update_show(show, show_params) do
      {:ok, show} ->
        conn
        |> put_flash(:info, "Show updated successfully.")
        |> redirect(to: Routes.show_path(conn, :show, Shows.name))

      {:errors, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", show: show, changeset: changeset, options: [method: "put"])
    end
  end

  def delete(conn, %{"id" => name}) do
    show = Shows.get_show!(name)
    {:ok, _show} = Shows.delete_show(show)

    conn
    |> put_flash(:info, "Show deleted successfully.")
    |> redirect(to: Routes.show_path(conn, :index))
  end
end
