defmodule AwardsVoter.Web.CategoryControllerTest do
  use AwardsVoter.Web.ConnCase, async: true

  alias AwardsVoter.Context.Admin

  @moduletag :do_show_setup

  defp category_count() do
    Enum.count(test_show().categories)
  end
  

  test "GET :edit renders form", %{conn: conn} do
    {:ok, show} = saved_test_show()
    category = test_category()

    conn = get(conn, Routes.show_category_path(conn, :edit, show.name, category.name))

    assert html_response(conn, 200) =~ "Edit Category"
    assert conn.resp_body =~ category.name
  end

  test "GET :new renders blank form", %{conn: conn} do
    {:ok, show} = saved_test_show()
    
    conn = get(conn, Routes.show_category_path(conn, :new, show.name))

    assert html_response(conn, 200) =~ "Adding New Category"
    refute conn.resp_body =~ test_category().name
  end

  test "GET :show displays details for selected category, redirects if not found", %{conn: conn} do
    {:ok, show} = saved_test_show()
    category = test_category()

    conn = get(conn, Routes.show_category_path(conn, :show, show.name, category.name))

    assert html_response(conn, 200) =~ category.name
    for contestant <- category.contestants do
      assert conn.resp_body =~ contestant.name
    end
    
    not_found_conn = get(conn, Routes.show_category_path(conn, :show, show.name, "Fake Name"))
    assert redirected_to(not_found_conn) == Routes.show_path(conn, :show, show.name)
  end

  @tag :do_ballots_setup
  test "POST :create should add a new category to show in table and redirect", %{conn: conn} do
    {:ok, show} = saved_test_show()
    create_attrs = test_category() |> Admin.category_to_map()
    category_name = Map.get(create_attrs, :name)
    show_name_uri = URI.encode(show.name)

    create_conn = post(conn, Routes.show_category_path(conn, :create, show.name), category: create_attrs)

    assert %{name: ^show_name_uri} = redirected_params(create_conn)
    assert redirected_to(create_conn) == Routes.show_path(conn, :show, show.name)

    conn = get(conn, Routes.show_category_path(conn, :show, show.name, category_name))

    assert html_response(conn, 200) =~ category_name
    assert Admin.get_category_from_show(show.name, category_name) == {:ok, test_category()}
  end

  test "POST :create does not create category, renders errors on invalid", %{conn: conn} do
    {:ok, show} = saved_test_show()
    count_before = category_count()
    invalid_attrs = %{description: "check", name: nil}

    conn = post(conn, Routes.show_category_path(conn, :create, show.name), category: invalid_attrs)

    assert html_response(conn, 200) =~ "check the errors"
    assert category_count() == count_before
  end

  @tag :do_ballots_setup
  test "PUT :update updates user category and redirects", %{conn: conn} do
    {:ok, show} = saved_test_show()
    
    updated_name = "Test Updated Name"
    updated_category = %{test_category() | name: updated_name}
    update_attrs = updated_category |> Admin.category_to_map()
    category_name_uri = URI.encode(updated_name)
    show_name_uri = URI.encode(show.name)
    
    update_conn = put(conn, Routes.show_category_path(conn, :update, show.name, test_category().name), category: update_attrs)

    assert %{name: ^category_name_uri, show_name: ^show_name_uri} = redirected_params(update_conn)
    assert redirected_to(update_conn) == Routes.show_category_path(update_conn, :show, show.name, updated_name)

    conn = get(conn, Routes.show_category_path(conn, :show, show.name, updated_name))

    assert html_response(conn, 200) =~ updated_name
    assert Admin.get_category_from_show(show.name, updated_name) == {:ok, updated_category}
    assert Admin.get_category_from_show(show.name, test_category().name) == :category_not_found
  end

  @tag :do_ballots_setup
  test "PUT :update with invalid attrs will render form with error message", %{conn: conn} do
    {:ok, show} = saved_test_show()
    invalid_attrs = %{description: "check", name: nil}

    conn = put(conn, Routes.show_category_path(conn, :update, show.name, test_category().name), category: invalid_attrs)

    assert html_response(conn, 200) =~ "check the errors"
    assert Admin.get_category_from_show(show.name, test_category().name) == {:ok, test_category()}
  end

  @tag :do_ballots_setup
  test "DELETE :delete deletes chosen category", %{conn: conn} do
    {:ok, show} = saved_test_show()
    category = test_category()

    delete_conn = delete(conn, Routes.show_category_path(conn, :delete, show.name, category.name))

    assert redirected_to(delete_conn) == Routes.show_path(delete_conn, :show, show.name)
    assert redirected_to(get(conn, Routes.show_category_path(conn, :show, show.name, category.name))) == Routes.show_path(delete_conn, :show, show.name)
  end

  @tag :do_ballots_setup
  test "PUT :set_winner updates the winner of the category and sends a broadcast", %{conn: conn} do
    {:ok, show} = saved_test_show()
    channel_name = "ballots:#{URI.encode(show.name)}"
    AwardsVoter.Web.Endpoint.subscribe(channel_name)
    category = test_category()
    new_winner = category.contestants |> Enum.at(1)
    updated_category = %{category | winner: new_winner}

    update_conn = put(conn, Routes.show_category_path(conn, :set_winner, show.name, category.name, new_winner.name))

    assert_receive %Phoenix.Socket.Broadcast{event: "winner_updated", payload: %{}, topic: channel_name}
    AwardsVoter.Web.Endpoint.unsubscribe(channel_name)

    assert redirected_to(update_conn) == Routes.show_category_path(update_conn, :show, show.name, category.name)

    conn = get(conn, Routes.show_category_path(conn, :show, show.name, category.name))

    assert html_response(conn, 200) =~ category.name
    assert conn.resp_body =~ new_winner.name
    assert Admin.get_category_from_show(show.name,category.name) == {:ok, updated_category}
  end
end
