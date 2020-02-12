defmodule AwardsVoter.Context.Admin.ShowTest do
  use AwardsVoter.DataCase, async: true

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Admin.Shows
  
  @moduletag :do_show_setup

  describe "Shows.create_show/2" do
    test "calls save_or_update_shows method if changeset is valid" do
      defmodule ShowModuleCreateValid do
        def save_or_update_shows(show) do
          expected = test_show()
          assert ^expected = show
          {:ok, show}
        end
      end
      
      show_map = test_show() |> Admin.show_to_map()
      refute Map.get(show_map, :__struct__)
      assert {:ok, saved_show} = Shows.create_show(show_map, ShowModuleCreateValid)
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
        def save_or_update_shows(show) do
          expected = test_show() |> Map.update!(:categories, fn _ -> [] end)
          assert ^expected = show
          {:ok, show}
        end
      end
      
      updated_show = test_show() |> Map.update!(:categories, fn _ -> [] end)
      updated_show_attrs = updated_show  |> Admin.show_to_map()
      refute Map.get(updated_show_attrs, :__struct__)
      
      {:ok, saved_show} = Shows.update_show(test_show(), updated_show_attrs, ShowModuleUpdateExceptName)
      assert ^saved_show = updated_show
    end
    
    test "call delete then save_or_update if name has been changed" do
      defmodule ShowModuleUpdateNameChange do
        def save_or_update_shows(show) do
          expected = test_show() |> Map.update!(:name, fn _ -> "Updated Name" end)
          assert ^expected = show
          {:ok, show}
        end
        
        def delete_show_entry(show_name) do
          assert ^show_name = test_show().name
          :ok
        end
      end
        
      updated_show = test_show() |> Map.update!(:name, fn _ -> "Updated Name" end)
      updated_show_attrs = updated_show  |> Admin.show_to_map()
      refute Map.get(updated_show_attrs, :__struct__)

      {:ok, saved_show} = Shows.update_show(test_show(), updated_show_attrs, ShowModuleUpdateNameChange)
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
        def delete_show_entry(show_name) do
          assert ^show_name = test_show().name
          :ok
        end
      end
      
      show = test_show()
      assert {:ok, ^show} = Shows.delete_show(show, ShowModuleDelete)
    end
    
    test "calls delete_show_entry and returns error tuple if call fails" do
      defmodule ShowModuleDeleteError do
        def delete_show_entry(_show_name) do
          {:delete_error, :reason}
        end
      end
      
      show = test_show()
      assert {:error, {:delete_error, :reason}} = Shows.delete_show(show, ShowModuleDeleteError)
    end
  end
end
