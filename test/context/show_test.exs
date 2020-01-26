defmodule AwardsVoter.Context.Admin.Shows.ShowTest do
  use ExUnit.Case, async: true

  alias __MODULE__
  alias AwardsVoter.Context.Admin.Categories.Category
  alias AwardsVoter.Context.Admin.Shows.Show

  def get_test_show() do
    %Show{
      categories: [
        %Category{name: "Billie", description: "She's a bad guy"},
        %Category{name: "Justin", description: "He's a bad guy too sometimes"}
      ],
      name: "The Test Show",
    }
  end

  describe "Show.new/2" do
    test "converts all of the passed in category Maps to %Category{} structs" do
      categories = [
        %Category{name: "Billie", description: "She's a bad guy"},
        %{name: "Justin", description: "He's a bad guy too sometimes"}
      ]

      assert Show.new("The Test Show", categories) == {:ok, get_test_show()}
    end
  end

  describe "Show.save_or_update_shows/1/2" do
    setup do
      [test_show: get_test_show()]
    end

    test "should return the same show in a tuple if upsert was successful", context do
      defmodule MockShowManager do
        def put(_name) do
          :ok
        end
      end
      expected = context[:test_show]
      assert {:ok, expected} = Show.save_or_update_shows(expected, MockShowManager)
    end
    test "should return :error_saving if there was an error saving", context do
      defmodule MockShowManager do
        def put(_name) do
          {:error, "Failure to insert"}
        end
      end
      expected = context[:test_show]
      assert :error_saving = Show.save_or_update_shows(expected, MockShowManager)
    end
    test "should return multiple entries in tuple when multiple shows are passed in", context do
      defmodule MockShowManager do
        def put(_name) do
          :ok
        end
      end
      expected = [context[:test_show], context[:test_show]]
      assert {:ok, expected} = Show.save_or_update_shows(expected, MockShowManager)
    end
    test "should return :error if there was an error saving any of the shows", context do
      defmodule MockShowManager do
        def put(_name) do
          {:error, "Failed to insert"}
        end
      end
      expected = [context[:test_show], context[:test_show]]
      assert :error_saving = Show.save_or_update_shows(expected, MockShowManager)
    end
  end

  describe "Show.get_show_by_name/1/2" do
    test "should return :not_found if there is no show by that name in table" do
      defmodule MockShowManager do
        def get(_name) do
          :not_found
        end
      end
      assert :not_found = Show.get_show_by_name("The Test Show", MockShowManager)
    end
    test "should return the show if one is found with a matching name" do
      defmodule MockShowManager do
        import ShowTest

        def get(_name) do
          get_test_show()
        end
      end

      show = ShowTest.get_test_show()
      assert {:ok, ^show} = Show.get_show_by_name("The Test Show", MockShowManager)
    end
  end

  describe "Show.delete_show_entry/1/2" do
    test "should return :ok if the show was successfully deleted from table" do
      defmodule MockShowManager do
        def delete(_name) do
          :ok
        end
      end
      assert :ok = Show.delete_show_entry("The Test Show", MockShowManager)
    end
    test "should return :error_deleting if there was no show by that name in table" do
      defmodule MockShowManager do
        def delete(_name) do
          {:error, "failed for some reason"}
        end
      end
      assert :error_deleting = Show.delete_show_entry("The Test Show", MockShowManager)
    end
  end
end
