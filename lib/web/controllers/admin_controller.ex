defmodule AwardsVoter.Web.AdminController do
  use AwardsVoter.Web, :controller

  alias AwardsVoter.Context.Admin

  require Logger

  def list_shows(conn, _params) do
    case Admin.get_all_shows() do
      shows when is_list(shows) -> render(conn, "index.html", shows: shows)
      e ->
        Logger.error("Error during Admin.get_all_shows: #{inspect e}")
        conn
        |> put_flash(:error, "Couldn't fetch shows")
        |> redirect(to: "/")
    end
  end
end
