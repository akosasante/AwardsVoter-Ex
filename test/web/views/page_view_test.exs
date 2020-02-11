defmodule AwardsVoter.Web.PageViewTest do
  use AwardsVoter.Web.ConnCase, async: true
  
  import Phoenix.View

  alias AwardsVoter.Context.Admin.Shows.Show
  alias AwardsVoter.Context.Admin.Categories.Category
  alias AwardsVoter.Context.Admin.Contestants.Contestant
  
  setup do
    show = %Show{
      name: "Test Show",
      categories: [
        %Category{
          name: "Test Category 1",
          contestants: [
            %Contestant{name: "Test Contestant 1"},
            %Contestant{name: "Test Contestant 2"}
          ]},
        %Category{name: "Test Category 2"},
        %Category{name: "Test Category 3"},
        %Category{name: "Test Category 4"}
      ]
    }
    {:ok, show: show}
  end
  
  test "renders 'index.html' correctly", %{conn: conn, show: show} do
    show2 = %{show | name: "Test Show 2"}
    shows = [show, show2]
    content = render_to_string(AwardsVoter.Web.PageView, "index.html", conn: conn, shows: shows)
    
    assert content =~ "Available Shows"
    
    for test_show <- shows do
      assert content =~ test_show.name
      assert content =~ "\"/ballot/#{URI.encode(test_show.name)}/new\">Start Ballot"
      assert content =~ "\"/ballot/#{URI.encode(test_show.name)}/continue\">Continue Existing Ballot"
      assert content =~ "\"/ballot/#{URI.encode(test_show.name)}/scoreboard\">See Scoreboard"
    end
  end
end
