defmodule AwardsVoterTest do
  use ExUnit.Case, async: true
  doctest AwardsVoter

  test "greets the world" do
    assert AwardsVoter.hello() == :world
  end
end
