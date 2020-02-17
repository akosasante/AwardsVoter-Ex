defmodule AwardsVoter.Context.AdminTest do
  use AwardsVoter.DataCase, async: false

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Admin.Shows.Show
  alias AwardsVoter.Context.Admin.Categories
  alias AwardsVoter.Context.Admin.Categories.Category
  alias AwardsVoter.Context.Admin.Contestants.Contestant
  
  defmodule MockShows do
    def get_show_by_name(show_name) do
      send(self(), :get_show)
      assert show_name == test_show().name
      {:ok, test_show()}
    end
    def update_show(show, attrs) do
      assert %Show{} = show
      assert %{categories: [%{} | _]} = attrs
      categories = Enum.map(attrs.categories, fn cat -> 
                                 Category.changeset(%Category{}, cat)
                                 |> Ecto.Changeset.apply_changes() end)
      show = %{show | categories: categories}
      send(self(), :update_show)
      {:ok, show}
    end
  end

  defmodule MockShowsAddCategory do
    def get_show_by_name(show_name) do
      send(self(), :get_show)
      assert show_name == test_show().name
      {:ok, %{test_show() | categories: []}}
    end
    def update_show(show, attrs), do: MockShows.update_show(show, attrs)
  end

  defmodule MockShowsAddContestant do
    def get_show_by_name(show_name) do
      send(self(), :get_show)
      assert show_name == test_show().name
      category = %{test_category() | contestants: []}
      {:ok, %{test_show() | categories: [category]}}
    end
    def update_show(show, attrs), do: MockShows.update_show(show, attrs)
  end
  
  defmodule MockInvalidShows do
    def get_show_by_name(show_name) do
      send(self(), :get_show)
      assert show_name != test_show().name
      :not_found
    end
  end
  
  defmodule MockVoter do
    def update_ballots_for_show(show) do
      assert %Show{} = show
      send(self(), :update_ballots)
    end
  end
  
  setup do
    Application.put_env(:awards_voter, :show_mod, MockShows)
    Application.put_env(:awards_voter, :voter_mod, MockVoter)
    :ok
  end
  
  describe "*_to_map methods" do
    test "contestant_to_map/1 should convert %Contestant{} struct to plain map" do
      contestant = %{test_contestant() | wiki_url: "example.com"}
      expected = %{
        name: contestant.name,
        billboard_stats: contestant.billboard_stats,
        description: contestant.description,
        image_url: contestant.image_url,
        spotify_url: contestant.spotify_url,
        wiki_url: contestant.wiki_url,
        youtube_url: contestant.youtube_url
      }
      res = Admin.contestant_to_map(contestant)
      
      assert Contestant == Map.get(contestant, :__struct__)
      refute Contestant == Map.get(res, :__struct__)
      assert res == expected
    end
    
    test "contestant_to_map/1 should no-op on plain maps" do
      contestant = %{
        name: test_contestant().name,
        billboard_stats: test_contestant().billboard_stats,
        description: test_contestant().description,
        image_url: test_contestant().image_url,
        spotify_url: test_contestant().spotify_url,
        wiki_url: test_contestant().wiki_url,
        youtube_url: test_contestant().youtube_url
      }
      res = Admin.contestant_to_map(contestant)

      refute Contestant == Map.get(res, :__struct__)
      assert res == contestant 
    end
    
    test "contestant_to_map/1 should no-op on nil" do
      res = Admin.contestant_to_map(nil)
      assert is_nil(res)
    end

    test "category_to_map/1 should convert %Category{} struct to plain map" do
      category = %{test_category() | contestants: [test_contestant()]}
      expected_contestant = %{
        name: test_contestant().name,
        billboard_stats: test_contestant().billboard_stats,
        description: test_contestant().description,
        image_url: test_contestant().image_url,
        spotify_url: test_contestant().spotify_url,
        wiki_url: test_contestant().wiki_url,
        youtube_url: test_contestant().youtube_url
      }
      expected = %{
        name: category.name,
        description: category.description,
        contestants: [expected_contestant],
        winner: expected_contestant,
      }
      res = Admin.category_to_map(category)

      assert Category == Map.get(category, :__struct__)
      refute Category == Map.get(res, :__struct__)
      assert Contestant == Map.get(category.contestants |> hd, :__struct__)
      refute Contestant == Map.get(res.contestants |> hd, :__struct__)
      assert res == expected
    end
    
    test "category_to_map/1 should no-op on plain maps" do
      expected_contestant = %{
        name: test_contestant().name,
        billboard_stats: test_contestant().billboard_stats,
        description: test_contestant().description,
        image_url: test_contestant().image_url,
        spotify_url: test_contestant().spotify_url,
        wiki_url: test_contestant().wiki_url,
        youtube_url: test_contestant().youtube_url
      }
      category = %{
        name: test_category().name,
        description: test_category().description,
        contestants: [expected_contestant],
        winner: expected_contestant,
      }
      res = Admin.category_to_map(category)

      refute Category == Map.get(res, :__struct__)
      refute Contestant == Map.get(res.contestants |> hd, :__struct__)
      assert res == category
    end
    
    test "category_to_map/1 should no-op on nil" do
      res = Admin.category_to_map(nil)
      assert is_nil(res)
    end

    test "show_to_map/1 should convert %Show{} struct to plain map" do
      category = %{test_category() | contestants: [test_contestant()]}
      show = %{test_show() | categories: [category]}
      expected_contestant = %{
        name: test_contestant().name,
        billboard_stats: test_contestant().billboard_stats,
        description: test_contestant().description,
        image_url: test_contestant().image_url,
        spotify_url: test_contestant().spotify_url,
        wiki_url: test_contestant().wiki_url,
        youtube_url: test_contestant().youtube_url
      }
      expected_category = %{
        name: category.name,
        description: category.description,
        contestants: [expected_contestant],
        winner: expected_contestant,
      }
      expected = %{
        name: show.name,
        categories: [expected_category]
      }
      res = Admin.show_to_map(show)

      assert Show == Map.get(show, :__struct__)
      refute Category == Map.get(res, :__struct__)
      assert Category == Map.get(show.categories |> hd, :__struct__)
      refute Category == Map.get(res.categories |> hd, :__struct__)
      assert Contestant == Map.get(show.categories |> hd |> Map.get(:contestants) |> hd, :__struct__)
      refute Contestant == Map.get(res.categories |> hd |> Map.get(:contestants) |> hd, :__struct__)
      assert res == expected
    end
    
    test "show_to_map/1 should no-op on plain maps" do
      expected_contestant = %{
        name: test_contestant().name,
        billboard_stats: test_contestant().billboard_stats,
        description: test_contestant().description,
        image_url: test_contestant().image_url,
        spotify_url: test_contestant().spotify_url,
        wiki_url: test_contestant().wiki_url,
        youtube_url: test_contestant().youtube_url
      }
      expected_category = %{
        name: test_category().name,
        description: test_category().description,
        contestants: [expected_contestant],
        winner: expected_contestant,
      }
      show = %{
        name: test_show().name,
        categories: [expected_category]
      }
      res = Admin.show_to_map(show)

      refute Category == Map.get(res, :__struct__)
      refute Category == Map.get(res.categories |> hd, :__struct__)
      refute Contestant == Map.get(res.categories |> hd |> Map.get(:contestants) |> hd, :__struct__)
      assert res == show
    end
    
    test "show_to_map/1 should no-op on nil" do
      res = Admin.show_to_map(nil)
      assert is_nil(res)
    end
  end
  
  describe "get_category_from_show/2" do
    test "returns success tuple upon fetching category" do
      res = Admin.get_category_from_show(test_show().name, test_category().name)
      
      assert {:ok, test_category()} == res
      assert_received :get_show
    end
    
    test "returns :show_not_found if show name is invalid" do
      Application.put_env(:awards_voter, :show_mod, MockInvalidShows)
      res = Admin.get_category_from_show("Invalid Show", test_category().name)
      
      assert :show_not_found == res
      assert_received :get_show
    end
    
    test "returns :category_not_found if category name is invalid" do
      res = Admin.get_category_from_show(test_show().name, "Invalid Category")
      
      assert :category_not_found == res
      assert_received :get_show
    end
  end
  
  describe "add_category_to_show/2" do
    test "returns success tuple upon adding category and saves result to both tables" do
      Application.put_env(:awards_voter, :show_mod, MockShowsAddCategory)
      category_map = test_category() |> Admin.category_to_map()
      expected_show = %{test_show() | categories: [test_category()]}
      res = Admin.add_category_to_show(test_show().name, category_map)
      
      assert {:ok, expected_show} == res
      assert_received :get_show
      assert_received :update_show
      assert_received :update_ballots
    end
    
    test "returns changeset with errors if category params are invalid" do
      res = Admin.add_category_to_show(test_show().name, %{name: nil, description: test_category().description})
      
      assert {:errors, cs} = res
      refute cs.valid?
      assert cs.errors
      assert_received :get_show
      refute_received :update_show
      refute_received :update_ballots
    end
    
    test "returns :show_not_found if show name is invalid" do
      Application.put_env(:awards_voter, :show_mod, MockInvalidShows)
      category_map = test_category() |> Admin.category_to_map()
      res = Admin.add_category_to_show("Invalid Show", category_map)      
      
      assert :show_not_found == res
      assert_received :get_show
      refute_received :update_show
      refute_received :update_ballots
    end
  end
  
  describe "update_show_category/3" do
    test "returns success tuple upon updating category and saves result to both tables" do
      expected_category = %{test_category() | description: "updated description"}
      category_map = expected_category |> Admin.category_to_map()
      assert {:ok, show} = Admin.update_show_category(test_show().name, test_category().name, category_map)
      
      res_category = show.categories |> hd
      assert res_category == expected_category
      assert_received :get_show
      assert_received :update_show
      assert_received :update_ballots
    end
    
    test "returns changeset with errors if category params are invalid" do
      res = Admin.update_show_category(test_show().name, test_category().name, %{name: nil, description: test_category().description})
      
      assert {:errors, cs} = res
      refute cs.valid?
      assert cs.errors
      assert_received :get_show
      refute_received :update_show
      refute_received :update_ballots
    end
    
    test "returns :show_not_found if show name is invalid" do
      Application.put_env(:awards_voter, :show_mod, MockInvalidShows)
      category_map = test_category() |> Admin.category_to_map()
      res = Admin.update_show_category("Invalid Show", test_category().name, category_map)

      assert :show_not_found == res
      assert_received :get_show
      refute_received :update_show
      refute_received :update_ballots
    end
    
    test "returns :category_not_found if category name is invalid" do
      category_map = test_category() |> Admin.category_to_map()
      res = Admin.update_show_category(test_show().name, "Invalid Category", category_map)
      
      assert :category_not_found == res
      assert_received :get_show
      refute_received :update_show
      refute_received :update_ballots
    end
  end
  
  describe "delete_show_category/2" do
    test "returns success tuple upon deleting category from show and saves result to both tables" do
      {:ok, show} = Admin.delete_show_category(test_show().name, test_category().name)
      
      assert Enum.count(show.categories) < Enum.count(test_show().categories)
      assert Enum.filter(show.categories, fn cat -> cat.name == test_category().name end) |> Enum.empty?
      assert_received :get_show
      assert_received :update_show
      assert_received :update_ballots
    end
    
    test "returns :show_not_found if show name is invalid" do
      Application.put_env(:awards_voter, :show_mod, MockInvalidShows)
      res = Admin.delete_show_category("Invalid Show", test_category().name)
      
      assert res == :show_not_found
      assert_received :get_show
      refute_received :update_show
      refute_received :update_ballots
    end
    
    test "returns :category_not_found if category name is invalid" do
      res = Admin.delete_show_category(test_show().name, "Invalid Category")
      
      assert res == :category_not_found
      assert_received :get_show
      refute_received :update_show
      refute_received :update_ballots
    end
  end

  describe "get_contestant_from_show/3" do
    test "returns success tuple upon fetching contestant" do
      {:ok, contestant} = Admin.get_contestant_from_show(test_show().name, test_category().name, test_contestant().name)
      
      assert contestant == test_contestant()
      assert_received :get_show
    end
    
    test "returns :show_not_found if show name is invalid" do
      Application.put_env(:awards_voter, :show_mod, MockInvalidShows)
      res = Admin.get_contestant_from_show("Invalid Show", test_category().name, test_contestant().name)
      
      assert res == :show_not_found
      assert_received :get_show
    end
    
    test "returns :category_not_found if category name invalid" do
      res = Admin.get_contestant_from_show(test_show().name, "Invalid Category", test_contestant().name)
      
      assert res == :category_not_found
      assert_received :get_show
    end
    
    test "returns :contestant_not_found if contestant name invalid" do
      res = Admin.get_contestant_from_show(test_show().name, test_category().name, "Invalid Contestant")
      
      assert res == :contestant_not_found
      assert_received :get_show
    end
  end
  
  describe "add_contestant_to_show_category/3" do
    test "returns success tuple upon adding contestant and saves result to show and ballot tables" do
      Application.put_env(:awards_voter, :show_mod, MockShowsAddContestant)
      contestant_map = test_contestant() |> Admin.contestant_to_map()
      expected_category = %{test_category() | contestants: [test_contestant()]}
      expected_show = %{test_show() | categories: [expected_category]}
      res = Admin.add_contestant_to_show_category(test_show().name, test_category().name, contestant_map)
      
      assert {:ok, expected_show} == res
      assert_received :get_show
      assert_received :update_show
      assert_received :update_ballots
    end
    
    test "returns changeset with errors if contestant params are invalid" do
      res = Admin.add_contestant_to_show_category(test_show().name, test_category().name, %{name: nil})
      
      assert {:errors, cs} = res
      refute cs.valid?
      assert cs.errors
      assert_received :get_show
      refute_received :update_show
      refute_received :update_ballots
    end
    
    test "returns :show_not_found if show name is invalid" do
      Application.put_env(:awards_voter, :show_mod, MockInvalidShows)
      contestant_map = test_contestant() |> Admin.contestant_to_map()
      res = Admin.add_contestant_to_show_category("Invalid Show", test_category().name, contestant_map)

      assert :show_not_found == res
      assert_received :get_show
      refute_received :update_show
      refute_received :update_ballots
    end
    
    test "returns :category_not_found if category name invalid" do
      contestant_map = test_contestant() |> Admin.contestant_to_map()
      res = Admin.add_contestant_to_show_category(test_show().name, "Invalid Category", contestant_map)

      assert :category_not_found == res
      assert_received :get_show
      refute_received :update_show
      refute_received :update_ballots
    end
  end
  
  describe "update_contestant_in_show_category/4" do
    test "returns success tuple upon updating contestant and saves result to show and ballot tables" do
      expected_contestant = %{test_contestant() | image_url: "example.gif"}
      contestant_map = expected_contestant |> Admin.contestant_to_map()
      assert {:ok, show} = Admin.update_contestant_in_show_category(test_show().name, test_category().name, test_contestant().name, contestant_map)
      
      res_contestant = show.categories |> hd |> Map.get(:contestants) |> hd
      assert res_contestant == expected_contestant
      assert_received :get_show
      assert_received :update_show
      assert_received :update_ballots
    end
    
    test "returns changeset with errors if contestant params are invalid" do
      res = Admin.update_contestant_in_show_category(test_show().name, test_category().name, test_contestant().name, %{name: nil})

      assert {:errors, cs} = res
      refute cs.valid?
      assert cs.errors
      assert_received :get_show
      refute_received :update_show
      refute_received :update_ballots
    end
    
    test "returns :show_not_found if show name is invalid" do
      Application.put_env(:awards_voter, :show_mod, MockInvalidShows)
      contestant_map = test_contestant() |> Admin.contestant_to_map()
      res = Admin.update_contestant_in_show_category("Invalid Show", test_category().name, test_contestant().name, contestant_map)

      assert :show_not_found == res
      assert_received :get_show
      refute_received :update_show
      refute_received :update_ballots
    end
    
    test "returns :category_not_found if category name invalid" do
      contestant_map = test_contestant() |> Admin.contestant_to_map()
      res = Admin.update_contestant_in_show_category(test_show().name, "Invalid Category", test_contestant().name, contestant_map)

      assert :category_not_found == res
      assert_received :get_show
      refute_received :update_show
      refute_received :update_ballots
    end
    
    test "returns :contestant_not_found if contestant name invalid" do
      contestant_map = test_contestant() |> Admin.contestant_to_map()
      res = Admin.update_contestant_in_show_category(test_show().name, test_category().name, "Invalid Contestant", contestant_map)

      assert :contestant_not_found == res
      assert_received :get_show
      refute_received :update_show
      refute_received :update_ballots
    end
  end
  
  describe "delete_contestant_from_show_category/3" do
    test "returns success tuple upon deleting contestant from category and saves result to show and ballot tables" do
      {:ok, show} = Admin.delete_contestant_from_show_category(test_show().name, test_category().name, test_contestant().name)
      category = Enum.find(show.categories, fn cat -> cat.name == test_category().name end)
      
      assert Enum.count(category.contestants) < Enum.count(test_category().contestants)
      assert Enum.filter(category.contestants, fn cont -> cont.name == test_contestant().name end) |> Enum.empty?
      assert_received :get_show
      assert_received :update_show
      assert_received :update_ballots
    end
    
    test "returns :show_not_found if show name is invalid" do
      Application.put_env(:awards_voter, :show_mod, MockInvalidShows)
      res = Admin.delete_contestant_from_show_category("Invalid Show", test_category().name, test_contestant().name)
      
      assert res == :show_not_found
      assert_received :get_show
      refute_received :update_show
      refute_received :update_ballots
    end
    
    test "returns :category_not_found if category name invalid" do
      res = Admin.delete_contestant_from_show_category(test_show().name, "Invalid Category", test_contestant().name)
      
      assert res == :category_not_found
      assert_received :get_show
      refute_received :update_show
      refute_received :update_ballots
    end
    
    test "returns :contestant_not_found if contestant name invalid" do
      res = Admin.delete_contestant_from_show_category(test_show().name, test_category().name, "Invalid Contestant")
      
      assert res == :contestant_not_found
      assert_received :get_show
      refute_received :update_show
      refute_received :update_ballots
    end
  end
  
  describe "set_winner_for_show_category/3" do
    test "returns success tuple and sets winner successfully" do
      new_winner = Enum.at(test_category().contestants, 2)
      {:ok, show} = Admin.set_winner_for_show_category(test_show().name, test_category().name, new_winner.name)
      
      returned_category = show.categories |> hd
      assert returned_category.winner == new_winner
      assert_received :get_show
      assert_received :update_show
      assert_received :update_ballots
    end
    
    test "returns :show_not_found if passed an invalid show" do
      Application.put_env(:awards_voter, :show_mod, MockInvalidShows)
      new_winner = Enum.at(test_category().contestants, 2)
      res = Admin.set_winner_for_show_category("Invalid Show", test_category().name, new_winner.name)

      assert res == :show_not_found
      assert_received :get_show
      refute_received :update_show
      refute_received :update_ballots
    end
    
    test "returns :category_not_found if passed an invalid category" do
      new_winner = Enum.at(test_category().contestants, 2)
      res = Admin.set_winner_for_show_category(test_show().name, "Invalid Category", new_winner.name)

      assert res == :category_not_found
      assert_received :get_show
      refute_received :update_show
      refute_received :update_ballots
    end
    
    test "returns :invalid_winner if contestant_name not found" do
      res = Admin.set_winner_for_show_category(test_show().name, test_category().name, "Invalid Contestant")

      assert res == :invalid_winner
      assert_received :get_show
      refute_received :update_show
      refute_received :update_ballots
    end
  end
end
