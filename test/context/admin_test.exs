defmodule AwardsVoter.Context.AdminTest do
  use AwardsVoter.DataCase, async: false

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Admin.Shows.Show
  alias AwardsVoter.Context.Admin.Categories.Category
  alias AwardsVoter.Context.Admin.Contestants.Contestant
  
  defmodule MockShows do
    def update_show(show, attrs) do
      assert %Show{} = show
      assert %{categories: _} = attrs
      send(self(), :update_show)
      {:ok, show}
    end
  end
  
  defmodule MockVoter do
    def update_ballots_for_show(show) do
      assert %Show{} = show
      send(self(), :update_ballots)
    end
  end
  
  setup do
    Application.put_env(:awards_voter, :show_mod, MockShow)
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
    test "returns success tuple upon fetching category"
    test "returns :show_not_found if show name is invalid"
    test "returns :category_not_found if category name is invalid"
  end
  
  describe "add_category_to_show/2" do
    test "returns success tuple upon adding category and saves result to both tables"
    test "returns changeset with errors if category params are invalid"
    test "returns :show_not_found if show name is invalid"
  end
  
  describe "update_show_category/3" do
    test "returns success tuple upon updating category and saves result to both tables"
    test "returns changeset with errors if category params are invalid"
    test "returns :show_not_found if show name is invalid"
    test "returns :category_not_found if category name is invalid"
  end
  
  describe "delete_show_category/2" do
    test "returns success tuple upon deleting category from show and saves result to both tables"
    test "returns :show_not_found if show name is invalid"
    test "returns :category_not_found if category name is invalid"
  end

  describe "get_contestant_from_show/3" do
    test "returns success tuple upon fetching contestant"
    test "returns :show_not_found if show name is invalid"
    test "returns :category_not_found if category name invalid"
    test "returns :contestant_not_found if contestant name invalid"
  end
  
  describe "add_contestant_to_show_category/3" do
    test "returns success tuple upon adding contestant and saves result to show and ballot tables"
    test "returns changeset with errors if contestant params are invalid"
    test "returns :show_not_found if show name is invalid"
    test "returns :category_not_found if category name invalid"
  end
  
  describe "update_contestant_in_show_category/4" do
    test "returns success tuple upon updating contestant and saves result to show and ballot tables"
    test "returns changeset with errors if contestant params are invalid"
    test "returns :show_not_found if show name is invalid"
    test "returns :category_not_found if category name invalid"
  end
  
  describe "delete_contestant_from_show_category/3" do
    test "returns success tuple upon deleting contestant from category and saves result to show and ballot tables"
    test "returns :show_not_found if show name is invalid"
    test "returns :category_not_found if category name invalid"
    test "returns :contestant_not_found if contestant name invalid"
  end
  
  describe "set_winner_for_show_category/3" do
    test "returns success tuple and sets winner successfully"
    test "returns :invalid_winner if contestant_name not found"
  end
  
  
end
