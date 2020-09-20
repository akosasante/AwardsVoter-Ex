defmodule AwardsVoter.Context.Models.ContestantTest do
  use AwardsVoter.DataCase

  alias AwardsVoter.Context.Models.Contestant

  test "should return valid changeset if params are valid" do
    cs = Contestant.changeset(%Contestant{}, params_for(:contestant))

    assert cs.valid?
    assert %Ecto.Changeset{} = cs
  end

  test "should return errors if the required params are not provided" do
    contestant = params_for(:contestant) |> Map.update!(:name, fn _ -> nil end)
    cs = Contestant.changeset(%Contestant{}, contestant)

    refute cs.valid?
    assert errors_on(cs) == %{name: ["can't be blank"]}
  end
end
