defmodule AwardsVoter.Context.Admin.Contestants.ContestantTest do
  use AwardsVoter.DataCase, async: true

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Admin.Contestants.Contestant

  describe "Contestant.changeset/2" do
    test "should return valid changeset if params are valid" do
      cs = Contestant.changeset(%Contestant{}, %{name: test_contestant().name})

      assert cs.valid?
      assert %Ecto.Changeset{} = cs
    end

    test "should return errors if the required params are not provided" do
      contestant = test_contestant() |> Admin.contestant_to_map() |> Map.update!(:name, fn _ -> nil end)
      cs = Contestant.changeset(%Contestant{}, contestant)
      errors = Ecto.Changeset.traverse_errors(cs, fn {msg, _opts} -> msg end)

      refute cs.valid?
      assert errors == %{name: ["can't be blank"]}
    end
  end
end
