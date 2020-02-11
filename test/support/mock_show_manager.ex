defmodule AwardsVoter.Web.MockShowManager do
  
  alias AwardsVoter.Context.Admin.Shows.Show
  alias AwardsVoter.Context.Admin.Categories.Category
  alias AwardsVoter.Context.Admin.Contestants.Contestant
  
  @show %Show{
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
  def all() do
    show1 = @show
    show2 = %{show1 | name: "Test Show 2"}
    [{show1.name, show1}, {show2.name, show2}]
  end
end