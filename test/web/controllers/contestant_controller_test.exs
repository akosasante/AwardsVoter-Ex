defmodule AwardsVoter.Web.ContestantControllerTest do
  use AwardsVoter.Web.ConnCase

  alias AwardsVoter.Context.Admin

  @moduletag :do_show_setup

  defp contestant_count(show_name, category_name) do
    {:ok, category} = Admin.get_category_from_show(show_name, category_name)
    Enum.count(category.contestants)
  end


  test "GET :edit renders form", %{conn: conn} do
    {:ok, show} = saved_test_show()
    category = test_category()
    contestant = test_contestant()

    conn = get(conn, Routes.show_category_contestant_path(conn, :edit, show.name, category.name, contestant.name))

    assert html_response(conn, 200) =~ "Edit Contestant"
    assert conn.resp_body =~ contestant.name
  end

  test "GET :new renders blank form", %{conn: conn} do
    {:ok, show} = saved_test_show()
    category = test_category()

    conn = get(conn, Routes.show_category_contestant_path(conn, :new, show.name, category.name))

    assert html_response(conn, 200) =~ "Adding New Contestant"
    refute conn.resp_body =~ test_contestant().name
  end

  test "GET :show displays details for selected contestant, redirects if not found", %{conn: conn} do
    {:ok, show} = saved_test_show()
    category = test_category()
    contestant = test_contestant()

    conn = get(conn, Routes.show_category_contestant_path(conn, :show, show.name, category.name, contestant.name))

    assert html_response(conn, 200) =~ contestant.name
    
    not_found_conn = get(conn, Routes.show_category_contestant_path(conn, :show, show.name, category.name, "Fake Name"))
    assert redirected_to(not_found_conn) == Routes.show_category_path(conn, :show, show.name, category.name)
  end

  @tag :do_ballots_setup
  test "POST :create should add a new contestant to category/show in table and redirect", %{conn: conn} do
    {:ok, show} = saved_test_show()
    category = test_category()
    create_attrs = test_contestant() |> Admin.contestant_to_map()
    contestant_name = Map.get(create_attrs, :name)
    show_name_uri = URI.encode(show.name)
    category_uri = URI.encode(category.name)

    create_conn = post(conn, Routes.show_category_contestant_path(conn, :create, show.name, category.name), contestant: create_attrs)

    assert %{show_name: ^show_name_uri, name: ^category_uri} = redirected_params(create_conn)
    assert redirected_to(create_conn) == Routes.show_category_path(conn, :show, show.name, category.name)
 
    conn = get(conn, Routes.show_category_contestant_path(conn, :show, show.name, category.name, contestant_name))

    assert html_response(conn, 200) =~ contestant_name
    assert Admin.get_contestant_from_show(show.name, category.name, contestant_name) == {:ok, test_contestant()}
  end

  test "POST :create does not create contestant, renders errors on invalid", %{conn: conn} do
    {:ok, show} = saved_test_show()
    category = test_category()
    count_before = contestant_count(show.name, category.name)
    invalid_attrs = %{description: "check", name: nil}

    conn = post(conn, Routes.show_category_contestant_path(conn, :create, show.name, category.name), contestant: invalid_attrs)

    assert html_response(conn, 200) =~ "check the errors"
    assert contestant_count(show.name, category.name) == count_before
  end

  @tag :do_ballots_setup
  test "PUT :update updates user contestant and redirects", %{conn: conn} do
    {:ok, show} = saved_test_show()
    category = test_category()

    updated_name = "Test Updated Name"
    updated_contestant = %{test_contestant() | name: updated_name, image_url: "test.gif"}
    update_attrs = updated_contestant |> Admin.contestant_to_map()
    contestant_name_uri = URI.encode(updated_name)
    category_uri = URI.encode(category.name)
    show_name_uri = URI.encode(show.name)

    update_conn = put(conn, Routes.show_category_contestant_path(conn, :update, show.name, category.name, test_contestant().name), contestant: update_attrs)

    assert %{name: ^contestant_name_uri, category_name: ^category_uri, show_name: ^show_name_uri} = redirected_params(update_conn)
    assert redirected_to(update_conn) == Routes.show_category_contestant_path(update_conn, :show, show.name, category.name, updated_name)

    conn = get(conn, Routes.show_category_contestant_path(conn, :show, show.name, category.name, updated_name))

    assert html_response(conn, 200) =~ updated_name
    assert Admin.get_contestant_from_show(show.name, category.name, updated_name) == {:ok, updated_contestant}
    assert Admin.get_contestant_from_show(show.name, category.name, test_contestant().name) == :contestant_not_found
  end

  @tag :do_ballots_setup
  test "PUT :update with invalid attrs will render form with error message", %{conn: conn} do
    {:ok, show} = saved_test_show()
    category = test_category()
    invalid_attrs = %{description: "check", name: nil}

    conn = put(conn, Routes.show_category_contestant_path(conn, :update, show.name, category.name, test_contestant().name), contestant: invalid_attrs)

    assert html_response(conn, 200) =~ "check the errors"
    assert Admin.get_contestant_from_show(show.name, category.name, test_contestant().name) == {:ok, test_contestant()}
  end

  @tag :do_ballots_setup
  test "DELETE :delete deletes chosen contestant", %{conn: conn} do
    {:ok, show} = saved_test_show()
    category = test_category()
    contestant = test_contestant()

    delete_conn = delete(conn, Routes.show_category_contestant_path(conn, :delete, show.name, category.name, contestant.name))

    assert redirected_to(delete_conn) == Routes.show_category_path(delete_conn, :show, show.name, category.name)
    assert redirected_to(get(conn, Routes.show_category_contestant_path(conn, :show, show.name, category.name, contestant.name))) == Routes.show_category_path(delete_conn, :show, show.name, category.name)
  end
end
