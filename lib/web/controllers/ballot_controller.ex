defmodule AwardsVoter.Web.BallotController do
  use AwardsVoter.Web, :controller

  require Logger

  def get_ballot(conn, %{"id" => id}) do
    render(conn, :get_ballot, ballot: id)
  end
end
