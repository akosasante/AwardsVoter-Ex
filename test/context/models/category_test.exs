defmodule AwardsVoter.Context.Models.CategoryTest do
  use AwardsVoter.DataCase

  alias AwardsVoter.Context.Models.Category

  test "should return valid changeset if params are valid" do
    cs = Category.changeset(%Category{}, params_for(:category, %{has_winner: true}))

    assert cs.valid?
    assert %Ecto.Changeset{} = cs
  end

  test "should return errors if the required params are not provided" do
    category = params_for(:category) |> Map.update!(:name, fn _ -> nil end)
    cs = Category.changeset(%Category{}, category)

    refute cs.valid?
    assert errors_on(cs) == %{name: ["can't be blank"]}
  end
end
