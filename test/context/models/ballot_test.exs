defmodule AwardsVoter.Context.Models.BallotTest do
  use AwardsVoter.DataCase

  alias AwardsVoter.Context.Models.Show

  test "should return valid changeset if params are valid" do
    cs = Show.changeset(%Show{}, params_for(:show))

    assert cs.valid?
    assert %Ecto.Changeset{} = cs
  end

  test "should return errors if the required params are not provided" do
    show = params_for(:show) |> Map.update!(:name, fn _ -> nil end)
    cs = Show.changeset(%Show{}, show)

    refute cs.valid?
    assert errors_on(cs) == %{name: ["can't be blank"]}
  end
end
