defmodule AwardsVoter.Web.SummariesView do
  use AwardsVoter.Web, :view

  alias AwardsVoter.Context.Ballots
  alias AwardsVoter.Context.Models.Ballot
  alias AwardsVoter.Context.Models.Show

  def num_voted(%Ballot{votes: votes}) do
    Enum.count(votes, fn vote -> !is_nil(vote.contestant) end)
  end

  def num_correct_by_voted(ballot) do
    num_voted = num_voted(ballot)
    num_correct = num_correct(ballot)
    if num_voted == 0 or num_correct == 0 do
      "0.00"
    else
      div(num_correct, num_voted) |> div(1) |> Float.round(2)
    end
  end

  def num_correct_by_categories(ballot, show) do
    num_categories = num_categories(show)
    num_correct = num_correct(ballot)

    if num_categories == 0 or num_correct == 0 do
      "0.00"
    else
      div(num_correct, num_categories) |> div(1) |> Float.round(2)
    end
  end

  def num_winners(%Show{categories: categories}) do
    Enum.count(categories, fn category -> !is_nil(category.winner) end)
  end

  def num_categories(%Show{categories: categories}), do: Enum.count(categories)

  defp num_correct(ballot) do
    Ballots.count_correct_votes(ballot)
  end

end
