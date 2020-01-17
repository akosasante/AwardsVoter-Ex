defmodule AwardsSiteWeb.ShowController do
  use AwardsSiteWeb, :controller

  alias AwardsSite.Shows

  def index(conn, _params) do
    shows = Shows.list_shows()
    render(conn, "index.html", shows: shows)
  end
end