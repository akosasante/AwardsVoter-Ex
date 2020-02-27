defmodule AwardsVoter.Context.Admin.Categories.CategoryTest do
  use AwardsVoter.DataCase, async: true

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Admin.Categories.Category

  describe "Category.changeset/2" do
    test "should return valid changeset if params are valid" do
      cs = Category.changeset(%Category{}, %{name: test_category().name})

      assert cs.valid?
      assert %Ecto.Changeset{} = cs
    end

    test "should return errors if the required params are not provided" do
      category = test_category() |> Admin.category_to_map() |> Map.update!(:name, fn _ -> nil end)
      cs = Category.changeset(%Category{}, category)
      errors = Ecto.Changeset.traverse_errors(cs, fn {msg, _opts} -> msg end)

      refute cs.valid?
      assert errors == %{name: ["can't be blank"]}
    end

    test "should cast contestant maps and insert into the changeset" do
      contestants = test_category().contestants |> Enum.map(&Admin.contestant_to_map/1)
      cs = Category.changeset(%Category{}, %{name: test_category().name, contestants: contestants})

      assert cs.valid?
      assert %Ecto.Changeset{} = cs
      assert Enum.all?(cs.changes.contestants, fn c -> c.valid? end)
      cs_contestants = cs.changes.contestants |> Enum.map(fn c -> c.data.__struct__ end)
      assert Enum.all?(cs_contestants, fn cont_struct -> cont_struct == AwardsVoter.Context.Admin.Contestants.Contestant end)
    end

    test "should cast category winner map and insert into the changeset" do
      winner = test_category().winner |> Admin.contestant_to_map()
      cs = Category.changeset(%Category{}, %{name: test_category().name, winner: winner})

      assert cs.valid?
      assert %Ecto.Changeset{} = cs
      assert cs.changes.winner.valid?
      assert cs.changes.winner.data.__struct__ == AwardsVoter.Context.Admin.Contestants.Contestant
    end
  end
end
