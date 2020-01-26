defmodule AwardsVoter.Web.PageController do
  use AwardsVoter.Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
