defmodule AwardsVoter.Context.Tables.ShowTableTest do
  use AwardsVoter.DataCase, async: true

  alias AwardsVoter.Context.Tables.ShowTable

  setup do
    show_table_name = Application.get_env(:awards_voter, :show_table_name)
    {:ok, _} = :dets.open_file(show_table_name, file: './#{}.dets')
    :ok = :dets.delete_all_objects(show_table_name)

    {:ok, _} =
      start_supervised({AwardsVoter.Context.Tables.ShowTable, [table_name: show_table_name]})

    on_exit(fn ->
      #      IO.puts("Test complete. Cleaning up...")
      :dets.close(show_table_name)
    end)

    :ok
  end

  test "all/0 should return all the shows in the table" do
    show = build(:show)
    assert [] == ShowTable.all()
    ShowTable.save([{show.id, show}])
    assert [show] == ShowTable.all()
  end

  test "get/1 should return :not_found if show not found in table" do
    assert :not_found == ShowTable.get("some-random-key")
  end

  test "get/1 should return a show if found in the table" do
    show = build(:show)
    assert :not_found == ShowTable.get(show.id)
    ShowTable.save([{show.id, show}])
    assert show == ShowTable.get(show.id)
  end

  test "save/1 should insert and return new show if not already in table" do
    show = build(:show)

    assert :ok = ShowTable.save([{show.id, show}])
    assert [show] == ShowTable.all()
  end

  test "save/1 should insert/update in dets based on show id already existing" do
    show_1 = build(:show)
    :ok = ShowTable.save([{show_1.id, show_1}])
    assert [show_1] == ShowTable.all()

    show_2 = build(:show)
    new_show = %{show_1 | name: "Updated show", categories: []}

    assert show_1.id == new_show.id
    assert :ok = ShowTable.save([{new_show.id, new_show}, {show_2.id, show_2}])
    assert [new_show, show_2] == ShowTable.all()
  end

  test "delete/1 should return :ok if it successfully deleted show from table" do
    show = build(:show)
    :ok = ShowTable.save([{show.id, show}])
    assert [show] == ShowTable.all()

    assert :ok = ShowTable.delete(show.id)
    assert [] == ShowTable.all()
  end
end
