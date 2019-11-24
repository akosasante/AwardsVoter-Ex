defmodule AwardsVoterTest do
  use ExUnit.Case
  doctest AwardsVoter

  test "greets the world" do
    assert AwardsVoter.hello() == :world
  end
end
