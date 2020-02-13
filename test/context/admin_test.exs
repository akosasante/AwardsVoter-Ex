defmodule AwardsVoter.Context.AdminTest do
  use AwardsVoter.DataCase, async: false

  defmodule MockShows do
    def update_show(show, attrs) do
      assert %Show{} = show
      assert %{categories: _} = attrs
      send(self(), {:update_show})
      {:ok, show}
    end
  end
  
  defmodule MockVoter do
    def update_ballots_for_show(show) do
      assert %Show{} = show
      send(self(), {:update_ballots})
    end
  end
  
  setup do
    Application.put_env(:awards_voter, :show_mod, MockShow)
    Application.put_env(:awards_voter, :voter_mod, MockVoter)
    :ok
  end
  
  describe "*_to_map methods" do
    test "contestant_to_map/1 should convert %Contestant{} struct to plain map"
    test "contestant_to_map/1 should no-op on plain maps"
    test "contestant_to_map/1 should no-op on nil"

    test "category_to_map/1 should convert %Contestant{} struct to plain map"
    test "category_to_map/1 should no-op on plain maps"
    test "category_to_map/1 should no-op on nil"

    test "show_to_map/1 should convert %Contestant{} struct to plain map"
    test "show_to_map/1 should no-op on plain maps"
    test "show_to_map/1 should no-op on nil"
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
