defmodule AwardsVoter.Web.PageController do
  use AwardsVoter.Web, :controller
  
  alias AwardsVoter.Context.Admin.Shows
  alias AwardsVoter.Context.Admin.Shows.Show
  
  require Logger

  def index(conn, _params) do
    case Shows.list_shows() do
      {:ok, shows} -> render(conn, "index.html", shows: shows, is_admin: false)
      e ->
        Logger.error("Error during Shows.list_show: #{inspect e}")
        conn
        |> put_flash(:error, "Could't fetch shows")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end
end
