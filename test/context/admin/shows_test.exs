defmodule AwardsVoter.Context.Admin.ShowTest do
  use AwardsVoter.DataCase

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Admin.Shows

  describe "Shows.create_show/2" do
    test "calls save_or_update_shows method if changeset is valid" do
      defmodule ShowModuleCreateValid do
        def put(_show_tuples), do: :ok
      end
      Application.put_env(:awards_voter, :show_manager_mod, ShowModuleCreateValid)
      show_map = test_show() |> Admin.show_to_map()

      refute Map.get(show_map, :__struct__)
      assert {:ok, saved_show} = Shows.create_show(show_map)
      assert ^saved_show = test_show()
    end

    test "returns changeset with action :create and errors if invalid" do
      {:errors, cs} = Shows.create_show(%{name: nil, categories: []})
      assert %Ecto.Changeset{} = cs
      assert :create = cs.action
      assert cs.errors
    end
  end

  describe "Shows.update_show/3" do
    test "calls only save_or_update_shows method if name has not been changed" do
      defmodule ShowModuleUpdateExceptName do
        def put(_show_tuple), do: :ok
      end
      Application.put_env(:awards_voter, :show_manager_mod, ShowModuleUpdateExceptName)
      updated_show = test_show() |> Map.update!(:categories, fn _ -> [] end)
      updated_show_attrs = updated_show  |> Admin.show_to_map()
      refute Map.get(updated_show_attrs, :__struct__)

      {:ok, saved_show} = Shows.update_show(test_show(), updated_show_attrs)
      assert ^saved_show = updated_show
    end

    test "call delete then save_or_update if name has been changed" do
      defmodule ShowModuleUpdateNameChange do
        def put(_show_tuple), do: :ok

        def delete(show_name) do
          assert ^show_name = test_show().name
          :ok
        end
      end
      Application.put_env(:awards_voter, :show_manager_mod, ShowModuleUpdateNameChange)
      updated_show = test_show() |> Map.update!(:name, fn _ -> "Updated Name" end)
      updated_show_attrs = updated_show  |> Admin.show_to_map()
      refute Map.get(updated_show_attrs, :__struct__)

      {:ok, saved_show} = Shows.update_show(test_show(), updated_show_attrs)
      assert ^saved_show = updated_show
    end

    test "returns changeset with action :update and errors if invalid" do
      {:errors, cs} = Shows.update_show(test_show(), %{name: nil, categories: []})
      assert %Ecto.Changeset{} = cs
      assert :update = cs.action
      assert cs.errors
    end
  end

  describe "Shows.delete_show/2" do
    test "calls delete_show_entry and returns positive tuple if successful" do
      defmodule ShowModuleDelete do
        def delete(show_name) do
          assert ^show_name = test_show().name
          :ok
        end
      end
      Application.put_env(:awards_voter, :show_manager_mod, ShowModuleDelete)
      show = test_show()

      assert {:ok, ^show} = Shows.delete_show(show)
    end

    test "calls delete_show_entry and returns error tuple if call fails" do
      defmodule ShowModuleDeleteError do
        def delete(_show_name) do
          {:error, :reason}
        end
      end
      Application.put_env(:awards_voter, :show_manager_mod, ShowModuleDeleteError)
      show = test_show()

      assert {:error, :error_deleting} = Shows.delete_show(show)
    end
  end
end
