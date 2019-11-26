IO.puts("Setting up AwardsVoter for console")
#import_if_available(AwardsVoter)
alias AwardsVoter.{Ballot, Category, Contestant, Show, Vote}

defmodule IexDev do
  def make_contestants(contestant_list) do
    Enum.map(contestant_list, fn contestant_name -> Contestant.new(contestant_name) end)
    |> Enum.map(fn {:ok, contestant} -> contestant end)
  end
end

category_names = ["Best New Artist", "Best New Song", "Best New Album"]

test_contestants = %{
  "Best New Artist" => IexDev.make_contestants(["Billie", "Justin", "Lil Nas X"]),
  "Best New Song" => IexDev.make_contestants(["Bad Guy", "Sorry", "Panini"]),
  "Best New Album" => IexDev.make_contestants(["XXX", "YYY", "ZZZ"])
}
test_categories = Enum.map(category_names, fn category -> Category.new(category, test_contestants[category]) end)
                  |> Enum.map(fn {:ok, category} -> category end)
{:ok, test_show} = Show.new("MyGrammys 2019", test_categories)
{:ok, test_ballot} = Ballot.new("KwasiVotesXYZ", test_show)