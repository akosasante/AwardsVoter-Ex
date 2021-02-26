IO.puts("Setting up AwardsVoter for console")
 import_if_available(AwardsVoter)
# alias AwardsVoter.Context.Voting.Ballots
# alias AwardsVoter.Context.Voting.Votes
# alias AwardsVoter.Context.Voting
 alias AwardsVoter.Context.Admin
 alias AwardsVoter.Context.Ballots
 alias AwardsVoter.Context.Models
# alias AwardsVoter.Context.Admin.Categories
# alias AwardsVoter.Context.Admin.Contestants
#
# defmodule IexDev do
#  def make_contestants(contestant_list) do
#    Enum.map(contestant_list, fn contestant_name -> Contestant.new(contestant_name) end)
#    |> Enum.map(fn {:ok, contestant} -> contestant end)
#  end
# end
#
# category_names = ["Best New Artist", "Best New Song", "Best New Album"]
# contestant_names = ["Billie", "Justin", "Lil Nas X", "Bad Guy", "Sorry", "Panini", "XXX", "YYY", "ZZZ"]
#
# test_contestants = Enum.map(contestant_names, fn cont ->
#  {:ok, contestant} = Contestants.create_contestant(%{name: cont})
#  contestant
# end)
# test_categories = category_names \
#                  |> Enum.with_index() \
#                  |> Enum.map(fn {cat, index} -> \
#                    contestants = Enum.chunk_every(test_contestants, 3) |> Enum.at(index) |> Enum.map(&Admin.contestant_to_map/1)
#                    {:ok, category} = Categories.create_category(%{name: cat, contestants: contestants})
#                    category \
#                  end)
# {:ok, test_show} = Shows.create_show(%{name: "My Grammys 2019", categories: test_categories |> Enum.map(&Admin.category_to_map/1)})
#
# {:ok, test_ballot} = Ballots.create_ballot_from_show_or_categories("KwasiVotesXYZ", test_show)
