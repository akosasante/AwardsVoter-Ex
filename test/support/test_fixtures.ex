defmodule AwardsVoter.TestFixtures do
  
  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Admin.Shows.Show
  alias AwardsVoter.Context.Admin.Categories.Category
  alias AwardsVoter.Context.Admin.Contestants.Contestant
  
  def test_show(name \\ "Test Show") do
    %Show{
      name: name,
      categories: [
        %Category{
          name: "Test Category",
          description: "This is simply a test category.",
          winner: %Contestant{name: "Test Contestant 1"},
          contestants: [
            %Contestant{name: "Test Contestant 1"},
            %Contestant{name: "Test Contestant 2"},
            %Contestant{name: "Test Contestant 3"},
            %Contestant{name: "Test Contestant 4"}
          ]
        },
        %Category{name: "Test Category 2"},
        %Category{name: "Test Category 3"},
        %Category{name: "Test Category 4"}
      ]
    }
  end
  
  def test_category() do
    test_show().categories |> hd
  end
  
  def test_contestant() do
    test_show().categories |> hd |> Map.get(:contestants) |> hd
  end
  
  def saved_test_show(name \\ "Test Show") do
    test_show(name)
    |> Admin.show_to_map()
    |> Admin.create_show()
  end
end