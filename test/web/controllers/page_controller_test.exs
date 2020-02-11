defmodule AwardsVoter.Web.PageControllerTest do
  use AwardsVoter.Web.ConnCase

  test "GET / should not show admin interface elements", %{conn: conn} do
    conn = get(conn, Routes.page_path(conn, :index))
    assert html_response(conn, 200) =~ " <title>Awards Show Predictor</title>"
    refute conn.resp_body =~ "[Admin]"
  end
end
