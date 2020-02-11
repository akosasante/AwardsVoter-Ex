defmodule AwardsVoter.Web.ShowViewTest do
  use AwardsVoter.Web.ConnCase, async: true

  import Phoenix.View

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Admin.Shows.Show

  describe "renders templates correctly:" do
    setup do
      show = test_show()
      {:ok, show: show}
    end

    test "show.html", %{conn: conn, show: show} do
      content = render_to_string(AwardsVoter.Web.ShowView, "show.html", conn: conn, show: show)
      
      for category <- show.categories do
        assert content =~ category.name
        assert content =~ "/admin/shows/#{URI.encode(show.name)}/categories/#{URI.encode(category.name)}"
      end

      assert content =~ show.name
      assert content =~ "[ 2 nominee(s) ]"
      assert content =~ "See Details"
      assert content =~ "Edit"
      assert content =~ "Delete"
      assert content =~ "Add New Category"
      assert content =~ "Delete Show"
      assert content =~ "Back to All Shows"
    end

    test "form.html", %{conn: conn, show: show} do
      changeset = Admin.change_show(show)
      action = Routes.show_path(conn, :update, show.name)
      content = render_to_string(AwardsVoter.Web.ShowView, "form.html", conn: conn, changeset: changeset, action: action, options: [method: "put"])

      assert content =~ "<form"
      assert content =~ "value=\"put\""
      assert content =~ "Save"
      assert content =~ show.name
    end

    test "edit.html", %{conn: conn, show: show} do
      changeset = Admin.change_show(show)
      content = render_to_string(AwardsVoter.Web.ShowView, "edit.html", conn: conn, show: show, changeset: changeset, options: [method: "put"])

      assert content =~ "Edit Show"
      assert content =~ "Back"
      assert content =~ "<form"
      assert content =~ show.name
    end

    test "new.html", %{conn: conn, show: show} do
      changeset = Admin.change_show(%Show{})
      content = render_to_string(AwardsVoter.Web.ShowView, "new.html", conn: conn, show: show, changeset: changeset, options: [])

      assert content =~ "Adding New Show"
      assert content =~ "Back"
      assert content =~ "<form"
      refute content =~ show.name
    end

    test "index.html", %{conn: conn, show: show} do
      show2 = %{show | name: "Test Show 2"}
      shows = [show, show2]
      content = render_to_string(AwardsVoter.Web.ShowView, "index.html", conn: conn, shows: shows)

      assert content =~ "All Shows"
      assert content =~ "Add New Show"
      assert content =~ "Upload new show as JSON"
      assert content =~ "Submit"
      
      for show_instance <- shows do
        assert content =~ show_instance.name
        assert content =~ "\"/admin/shows/#{URI.encode(show_instance.name)}\">See Details"
        assert content =~ "\"/admin/shows/#{URI.encode(show_instance.name)}/edit\">Edit"
        assert content =~ "\"/admin/shows/#{URI.encode(show_instance.name)}\" rel=\"nofollow\">Delete"
      end
    end
  end
end