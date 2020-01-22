defmodule AwardsVoterWeb.PageController do
  use AwardsVoterWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
