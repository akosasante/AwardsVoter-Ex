defmodule AwardsVoter.Web.AdminController do
  use AwardsVoter.Web, :controller

  import Phoenix.LiveView.Controller

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Models.Show

  require Logger

  def admin_index(conn, params) do
    redirect(conn, to: "/admin/shows")
  end

  def list_shows(conn, _params) do
    case Admin.get_all_shows() do
      shows when is_list(shows) ->
        render(conn, :index, shows: shows)

      e ->
        Logger.error("Error during Admin.get_all_shows: #{inspect e}")

        conn
        |> put_flash(:error, "Couldn't fetch shows")
        |> redirect(to: "/")
    end
  end

  def get_show(conn, %{"id" => show_id}) do
    case Admin.get_show_by_id(show_id) do
      %Show{} = show ->
        conn
        |> assign(:show, show)
        |> live_render(AwardsVoter.Web.AdminShowDetails,
          show: show,
          session: %{"show_id" => show.id}
        )

      e ->
        Logger.error("Error during Admin.get_show: #{inspect e}")

        conn
        |> put_flash(:error, "Couldn't fetch show")
        |> redirect(to: "/")
    end
  end

  def upload_show_json(conn, %{"show_json" => %Plug.Upload{filename: filename, path: path}}) do
    try do
      parsed_show =
        File.read!(path)
        |> Jason.decode!(keys: :atoms)

      show = Admin.create_show(parsed_show)

      conn
      |> put_flash(:info, "Show created successfully.")
      |> redirect(to: Routes.admin_path(conn, :get_show, show.id))
    rescue
      e ->
        Logger.error("Error uploading show: #{inspect e}")
        redirect(conn, to: Routes.admin_path(conn, :list_shows))
    end
  end

  def delete_show(conn, %{"id" => show_id}) do
    case Admin.delete_show(show_id) do
      :ok ->
        conn
        |> put_flash(:info, "Show deleted successfully")
        |> redirect(to: Routes.admin_path(conn, :list_shows))

      {:error, error} ->
        conn
        |> put_flash(:error, "Failed to delete show due to: #{inspect error}")
        |> redirect(to: Routes.admin_path(conn, :get_show, show_id))
    end
  end
end
