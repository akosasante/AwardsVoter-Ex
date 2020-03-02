defmodule AwardsVoter.Context.Admin.Shows.ShowTest do
  use AwardsVoter.DataCase

  alias AwardsVoter.Context.Admin.Shows.Show
  alias AwardsVoter.Context.Admin
  Code.compiler_options(ignore_module_conflict: true) # ignore redefined modules that we use for our test mocks


  describe "Show.changeset/2" do
    test "should return errors if categories are invalid" do
      show = test_show()
      category = test_category()
      invalid_category = %{category | name: nil}
      show = %{show | categories: [invalid_category]} |> Admin.show_to_map()
      changeset = Show.changeset(%Show{}, show)
      errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)

      assert errors == %{categories: [%{name: ["can't be blank"]}]}
      refute changeset.valid?
    end

    test "should return errors if show name is not included" do
      show = test_show()
      show = %{show | name: nil} |> Admin.show_to_map()
      changeset = Show.changeset(%Show{}, show)
      errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)

      assert errors == %{name: ["can't be blank"]}
      refute changeset.valid?
    end

    test "should return changeset if params are valid" do
      show = test_show() |> Admin.show_to_map()
      changeset = Show.changeset(%Show{}, show)

      assert %Ecto.Changeset{} = changeset
      assert changeset.valid?
    end
  end

  describe "Show.save_or_update_shows/2" do
    defmodule PutShowManager do
      def put(show_tuple) do
        assert ^show_tuple = [{test_show().name, test_show()}]
        :ok
      end
    end

    test "should pass in tuples to show manager" do
      Application.put_env(:awards_voter, :show_manager_mod, PutShowManager)
      show = test_show()
      assert {:ok, ^show} = Show.save_or_update_shows(show)
    end

    test "should handle and return list of shows correctly" do
      Application.put_env(:awards_voter, :show_manager_mod, PutShowManager)
      show = test_show()
      assert {:ok, [^show]} = Show.save_or_update_shows([show])
    end
  end

  describe "Show.get_show_by_name/2" do
    test "should return {:ok, show} tuple if found" do
      defmodule GetShowManager do
        def get(_name) do
          test_show()
        end
      end
      Application.put_env(:awards_voter, :show_manager_mod, GetShowManager)
      show = test_show()
      assert {:ok, ^show} = Show.get_show_by_name(show)
    end

    test "should return :not_found if now show found" do
      defmodule GetShowManager do
        def get(_name) do
          :not_found
        end
      end
      Application.put_env(:awards_voter, :show_manager_mod, GetShowManager)
      show = test_show()
      assert :not_found = Show.get_show_by_name(show.name)
    end

    test "should return :error_finding if error returned" do
      defmodule GetShowManager do
        def get(_name) do
          {:error, :reason}
        end
      end
      Application.put_env(:awards_voter, :show_manager_mod, GetShowManager)
      show = test_show()
      assert :error_finding = Show.get_show_by_name(show.name)
    end
  end

  describe "Show.get_all_shows/1" do
    test "should return empty list if Erlang :end_of_table returned" do
      defmodule GetAllShowManager do
        def all() do
          :"$end_of_table"
        end
      end
      Application.put_env(:awards_voter, :show_manager_mod, GetAllShowManager)
      assert {:ok, []} = Show.get_all_shows()
    end

    test "should return show list if fetched successfully" do
      defmodule GetAllShowManager do
        def all() do
          [{test_show().name, test_show()}]
        end
      end
      Application.put_env(:awards_voter, :show_manager_mod, GetAllShowManager)
      show = test_show()
      assert {:ok, [^show]} = Show.get_all_shows()
    end

    test "should return :error_fetching if error returned" do
      defmodule GetAllShowManager do
        def all() do
          {:error, :reason}
        end
      end
      Application.put_env(:awards_voter, :show_manager_mod, GetAllShowManager)
      assert :error_fetching = Show.get_all_shows()
    end
  end

  describe "Show.delete_show_entry/2" do
    test "should return :error_deleting if error returned" do
      defmodule DeleteShowManager do
        def delete(_name) do
          {:error, :reason}
        end
      end
      Application.put_env(:awards_voter, :show_manager_mod, DeleteShowManager)
      assert :error_deleting = Show.delete_show_entry(test_show().name)
    end

    test "should return :ok if successfully deleted" do
      defmodule DeleteShowManager do
        def delete(_name) do
          :ok
        end
      end
      Application.put_env(:awards_voter, :show_manager_mod, DeleteShowManager)
      assert :ok = Show.delete_show_entry(test_show().name)
    end
  end
end
