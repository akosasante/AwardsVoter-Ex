defmodule AwardsVoter.Context.Admin.Shows.ShowManagerTest do
  use ExUnit.Case, async: false

  alias  AwardsVoter.Context.Admin.Categories.Category
  alias  AwardsVoter.Context.Admin.Shows.Show
  alias  AwardsVoter.Context.Admin.Shows.ShowManager

  @show_table Application.get_env(:awards_voter, :show_table)

  def setup_dets_file(_context) do
    :dets.open_file(@show_table, [])
    on_exit(fn ->
      :dets.open_file(@show_table, [])
      :dets.delete_all_objects(@show_table)
      :dets.close(@show_table)
    end)
  end

  def test_show(name \\ "The Test Show", categories \\ nil) do
    cats = if categories, do: categories, else: [
                                            %Category{name: "Billie", description: "She's a bad guy"},
                                            %Category{name: "Justin", description: "He's a bad guy too sometimes"}
    ]
    %Show{
      categories: cats,
      name: name,
    }
  end

  setup :setup_dets_file

  describe "Show Manager callbacks" do
    test "handle_call :get_all should return all the shows in the table" do
      show2_title = "Test Show #2"
      show = test_show()
      show2 = test_show(show2_title)
      show_tuples = [{show.name, show}, {show2.name, show2}]
      :dets.insert(@show_table, show_tuples)

      assert {:reply, ^show_tuples, _state} = ShowManager.handle_call(:get_all, :pid, :show_table)
    end
    test "handle_call {:lookup, key} should return :not_found if show not found in table" do
      assert {:reply, :not_found, _state} = ShowManager.handle_call({:lookup, test_show().name}, :pid, :show_table)
    end

    test "handle_call {:lookup, key} should return a show if found in the table" do
      show = test_show()
      :dets.insert(@show_table, {test_show().name, test_show()})
      assert {:reply, ^show, _state} = ShowManager.handle_call({:lookup, test_show().name}, :pid, :show_table)
    end

    test "handle_call {:insert, key_value_tuple} should insert and return new show if not already in table" do
      show = test_show()
      show_tuple = {show.name, show}

      assert {:reply, :ok, _state} = ShowManager.handle_call({:insert, [show_tuple]}, :pid, :show_table)
      assert :dets.lookup(@show_table, show.name) == [show_tuple]
    end

    test "handle_call {:insert, key_value_tuple} should update in dets if it already exists" do
      show = test_show()
      :dets.insert(@show_table, {test_show().name, test_show()})

      new_categories = [
        %Category{name: "Jackson", description: "She's a bad guy"},
        %Category{name: "Jeremy", description: "He's a bad guy too sometimes"}
      ]
      new_show = test_show(show.name, new_categories)
      show_tuple = {new_show.name, new_show}

      assert {:reply, :ok, _state} = ShowManager.handle_call({:insert, [show_tuple]}, :pid, :show_table)
      assert :dets.lookup(@show_table, show.name) == [show_tuple]
    end

    test "handle_call {:insert, key_value_tuple} should return and return upsert new shows passed in" do
      show2_title = "Test Show #2"
      show = test_show()
      show2 = test_show(show2_title)
      show_tuples = [{show.name, show}, {show2.name, show2}]

      assert {:reply, :ok, _state} = ShowManager.handle_call({:insert, show_tuples}, :pid, :show_table)
      assert ^show_tuples = :dets.match_object(@show_table, :_)

      new_categories = [
        %Category{name: "Jackson", description: "She's a bad guy"},
        %Category{name: "Jeremy", description: "He's a bad guy too sometimes"}
      ]
      updated_show = test_show(show2_title, new_categories)
      brand_new_show = test_show("Test Show #3")
      upsert_show_tuples = [{updated_show.name, updated_show}, {brand_new_show.name, brand_new_show}]
      expected = Enum.concat([{show.name, show}], upsert_show_tuples)

      assert {:reply, :ok, _state} = ShowManager.handle_call({:insert, upsert_show_tuples}, :pid, :show_table)
      assert ^expected = :dets.match_object(@show_table, :_)
    end

    test "handle_call {:delete, key} should return :ok if it successfully deleted show from table" do
      show = test_show()
      show_tuple = {show.name, show}
      :dets.insert(@show_table, {test_show().name, test_show()})
      assert :dets.lookup(@show_table, show.name) == [show_tuple]

      assert {:reply, :ok, _state} = ShowManager.handle_call({:delete, show.name}, :pid, :show_table)
      assert :dets.lookup(@show_table, show.name) == []
    end
  end
end
