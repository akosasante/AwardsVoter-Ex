defmodule AwardsVoter.Context.Models.VoteTest do
  use AwardsVoter.DataCase

  alias AwardsVoter.Context.Models.Vote

  test "should return valid changeset if params are valid" do
    cs = Vote.changeset(%Vote{}, params_for(:vote))

    assert cs.valid?
    assert %Ecto.Changeset{} = cs
  end

  test "should return errors if the required params are not provided" do
    vote = params_for(:vote) |> Map.update!(:category, fn _ -> nil end)
    cs = Vote.changeset(%Vote{}, vote)

    refute cs.valid?
    assert errors_on(cs) == %{category: ["can't be blank"]}
  end
end
