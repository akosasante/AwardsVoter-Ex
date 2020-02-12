defmodule AwardsVoter.Web.ShowControllerTest do
  use AwardsVoter.Web.ConnCase
  
  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Admin.Shows.Show
  
  @show1_name "Test Show 1"
  @show2_name "Test Show 2"
  @moduletag :do_show_setup
  
  defp show_count() do
    {:ok, shows} = Admin.list_shows()
    Enum.count(shows)
  end
  
  
  test "GET :index must show admin interface elements", %{conn: conn} do
    {:ok, _show} = saved_test_show(@show1_name)
    {:ok, _show} = saved_test_show(@show2_name)
    
    conn = get(conn, Routes.show_path(conn, :index))
    
    assert html_response(conn, 200) =~ "<title>Awards Show Predictor</title>"
    assert conn.resp_body =~ "[Admin]"
    assert conn.resp_body =~ @show1_name
    assert conn.resp_body =~ @show2_name
  end
  
  test "GET :edit renders form", %{conn: conn} do
    {:ok, _show} = saved_test_show(@show1_name)
    
    conn = get(conn, Routes.show_path(conn, :edit, @show1_name))
    
    assert html_response(conn, 200) =~ "Edit Show"
    assert conn.resp_body =~ @show1_name
  end
  
  test "GET :new renders blank form", %{conn: conn} do
    conn = get(conn, Routes.show_path(conn, :new))
    
    assert html_response(conn, 200) =~ "Adding New Show"
    refute conn.resp_body =~ @show1_name
  end
  
  test "GET :show displays details for selected show", %{conn: conn} do
    {:ok, _show} = saved_test_show(@show1_name)
    
    conn = get(conn, Routes.show_path(conn, :show, @show1_name))
    
    assert html_response(conn, 200) =~ @show1_name
    for category <- test_show(@show1_name).categories do
      assert conn.resp_body =~ category.name
    end
  end
  
  test "POST :create should add a new show to table and redirect", %{conn: conn} do
    create_attrs = test_show() |> Admin.show_to_map()
    show_name = Map.get(create_attrs, :name)
    show_name_uri = URI.encode(show_name)
    
    create_conn = post(conn, Routes.show_path(conn, :create), show: create_attrs)

    assert %{name: ^show_name_uri} = redirected_params(create_conn)
    assert redirected_to(create_conn) == Routes.show_path(create_conn, :show, show_name)
    
    conn = get(conn, Routes.show_path(conn, :show, show_name))
    
    assert html_response(conn, 200) =~ show_name
    assert Admin.get_show_by_name(show_name) == {:ok, test_show()}
  end

  test "POST :create does not create show, renders errors on invalid", %{conn: conn} do
    count_before = show_count()
    invalid_attrs = %{description: "check", name: nil}
    
    conn = post(conn, Routes.show_path(conn, :create), show: invalid_attrs)

    assert html_response(conn, 200) =~ "check the errors"
    assert show_count() == count_before
  end

  test "PUT :update updates user show and redirects", %{conn: conn} do
    {:ok, _show} = saved_test_show(@show1_name)
    updated_name = "Test Updated Name"
    updated_show = updated_name |> test_show()
    update_attrs = updated_show |> Admin.show_to_map()
    show_name_uri = URI.encode(updated_name)
    
    update_conn = put(conn, Routes.show_path(conn, :update, @show1_name), show: update_attrs)

    assert %{name: ^show_name_uri} = redirected_params(update_conn)
    assert redirected_to(update_conn) == Routes.show_path(update_conn, :show, updated_name)

    conn = get(conn, Routes.show_path(conn, :show, updated_name))

    assert html_response(conn, 200) =~ updated_name
    assert Admin.get_show_by_name(updated_name) == {:ok, updated_show}
  end

  test "DELETE :delete deletes chosen show", %{conn: conn} do
    {:ok, _show} = saved_test_show(@show1_name)

    delete_conn = delete(conn, Routes.show_path(conn, :delete, @show1_name))

    assert redirected_to(delete_conn) == Routes.show_path(delete_conn, :index)
    assert redirected_to(get(conn, Routes.show_path(conn, :show, @show1_name))) == Routes.show_path(delete_conn, :index)
  end
  
  test "POST :create_json creates a new show from json", %{conn: conn} do
    upload = %Plug.Upload{path: "test/support/test_show.json", filename: "example.json"}
    show_name = "62nd Grammy Awards"
    parsed_show = File.read!(upload.path) |> Jason.decode!(keys: :atoms)
    expected_show = Show.changeset(%Show{}, parsed_show) |> Ecto.Changeset.apply_changes()
    show_name_uri = URI.encode(show_name)

    create_conn = post(conn, Routes.show_path(conn, :create_json), show: upload)

    assert %{name: ^show_name_uri} = redirected_params(create_conn)
    assert redirected_to(create_conn) == Routes.show_path(create_conn, :show, show_name)

    conn = get(conn, Routes.show_path(conn, :show, show_name))

    assert html_response(conn, 200) =~ show_name
    assert Admin.get_show_by_name(show_name) == {:ok, expected_show}
  end
end
