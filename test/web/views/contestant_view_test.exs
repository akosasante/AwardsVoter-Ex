defmodule AwardsVoter.Web.ContestantViewTest do
  use AwardsVoter.Web.ConnCase, async: true

  import Phoenix.View

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Admin.Contestants.Contestant

  describe "renders templates correctly:" do
    setup do
      contestant = %Contestant{
        name: "Test Contestant",
        description: "This is simply a test category.",
        image_url: "https://via.placeholder.com/150",
        youtube_url: "https://www.youtube.com/embed/QaVlWoaBytQ",
        spotify_url: "https://open.spotify.com/embed/track/1oY3JA45HTXMGu6qdzMgOY"
      }
      {:ok, contestant: contestant, show_name: "Test Show", category_name: "Test Category"}
    end

    test "show.html", %{conn: conn, category_name: category_name, show_name: show_name, contestant: contestant} do
      content = render_to_string(AwardsVoter.Web.ContestantView, "show.html", conn: conn, contestant: contestant, show_name: show_name, category_name: category_name)

      assert content =~ contestant.name
      assert content =~ contestant.description
      assert content =~ "<img src=\"https://via.placeholder.com/150\" "
      assert content =~ "<iframe src=\"https://open.spotify.com/embed/track/1oY3JA45HTXMGu6qdzMgOY\""
      assert content =~ "<iframe class=\"mx-auto\" width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/QaVlWoaBytQ\""
      refute content =~ "Wiki Page"
      refute content =~ "Billboard Stats"
      assert content =~ "Back to Category"
      assert content =~ "Delete"
      assert content =~ "Edit"
    end

    test "form.html", %{conn: conn, contestant: contestant, show_name: show_name, category_name: category_name} do
      changeset = Admin.change_contestant(contestant)
      action = Routes.show_category_contestant_path(conn, :update, show_name, category_name, contestant.name)
      content = render_to_string(AwardsVoter.Web.ContestantView, "form.html", conn: conn, changeset: changeset, action: action, options: [method: "put"])

      assert content =~ "<form"
      assert content =~ "value=\"put\""
      assert content =~ "Save"
      assert content =~ contestant.name
      assert content =~ contestant.description
      assert content =~ contestant.youtube_url
      assert content =~ contestant.spotify_url
      assert content =~ contestant.image_url
    end

    test "edit.html", %{conn: conn, contestant: contestant, show_name: show_name, category_name: category_name} do
      changeset = Admin.change_contestant(contestant)
      content = render_to_string(AwardsVoter.Web.ContestantView, "edit.html", conn: conn, show_name: show_name, category_name: category_name, contestant_name: contestant.name, changeset: changeset, options: [method: "put"])

      assert content =~ "Edit Contestant"
      assert content =~ "Back"
      assert content =~ "<form"
      assert content =~ contestant.name
    end

    test "new.html", %{conn: conn, contestant: contestant, show_name: show_name, category_name: category_name} do
      changeset = Admin.change_contestant(%Contestant{})
      content = render_to_string(AwardsVoter.Web.ContestantView, "new.html", conn: conn, show_name: show_name, category_name: category_name, changeset: changeset, options: [])

      assert content =~ "Adding New Contestant"
      assert content =~ "Back"
      assert content =~ "<form"
      refute content =~ contestant.name
    end
  end
end