defmodule AwardsVoter.Web.CategoryViewTest do
  use AwardsVoter.Web.ConnCase, async: true
  
  import Phoenix.View
  
  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Admin.Categories.Category
  alias AwardsVoter.Context.Admin.Contestants.Contestant
  
  describe "renders templates correctly:" do
    setup do
      category = %Category{
        name: "Test Category",
        description: "This is simply a test category.",
        winner: %Contestant{name: "Test Contestant 1"},
        contestants: [
          %Contestant{name: "Test Contestant 1"},
          %Contestant{name: "Test Contestant 2"},
          %Contestant{name: "Test Contestant 3"},
          %Contestant{name: "Test Contestant 4"}
        ]
      }
      {:ok, category: category, show_name: "Test Show"}
    end
    
    test "show.html", %{conn: conn, category: category, show_name: show_name} do
      content = render_to_string(AwardsVoter.Web.CategoryView, "show.html", conn: conn, category: category, show_name: show_name)
      
      for contestant <- category.contestants do
        assert content =~ contestant.name
      end
      
      assert content =~ category.name
      assert content =~ category.description
      assert content =~ category.winner.name
      assert content =~ "Edit"
      assert content =~ "Contestants"
      assert content =~ "See Details"
      assert content =~ "Set as Winner"
      assert content =~ "Delete"
      assert content =~ "Add New Contestant"
      assert content =~ "Delete Category"
      assert content =~ "Back to Show"
    end
    
    test "form.html", %{conn: conn, category: category, show_name: show_name} do
      changeset = Admin.change_category(category)
      action = Routes.show_category_path(conn, :update, show_name, category.name)
      content = render_to_string(AwardsVoter.Web.CategoryView, "form.html", conn: conn, changeset: changeset, action: action, options: [method: "put"])
      
      assert content =~ "<form"
      assert content =~ "value=\"put\""
      assert content =~ "Save"
      assert content =~ category.name
      assert content =~ category.description
    end

    test "edit.html", %{conn: conn, category: category, show_name: show_name} do
      changeset = Admin.change_category(category)
      content = render_to_string(AwardsVoter.Web.CategoryView, "edit.html", conn: conn, show_name: show_name, category_name: category.name, changeset: changeset, options: [method: "put"])

      assert content =~ "Edit Category"
      assert content =~ "Back"
      assert content =~ "<form"
      assert content =~ category.name
    end

    test "new.html", %{conn: conn, category: category, show_name: show_name} do
      changeset = Admin.change_category(%Category{})
      content = render_to_string(AwardsVoter.Web.CategoryView, "new.html", conn: conn, show_name: show_name, changeset: changeset, options: [])

      assert content =~ "Adding New Category"
      assert content =~ "Back"
      assert content =~ "<form"
      refute content =~ category.name
    end
  end
end