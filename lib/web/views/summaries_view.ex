defmodule AwardsVoter.Web.SummariesView do
  use AwardsVoter.Web, :view

  alias AwardsVoter.Context.Ballots
  alias AwardsVoter.Context.Models.Ballot
  alias AwardsVoter.Context.Models.Vote
  alias AwardsVoter.Context.Models.Category
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
      div(num_correct, num_voted) |> Kernel./(1) |> Float.round(2)
    end
  end

  def num_correct_by_categories(ballot, show) do
    num_categories = num_categories(show)
    num_correct = num_correct(ballot)

    if num_categories == 0 or num_correct == 0 do
      "0.00"
    else
      div(num_correct, num_categories) |> Kernel./(1) |> Float.round(2)
    end
  end

  def num_winners(%Show{} = show) do
    Enum.count(winning_categories(show))
  end

  def num_categories(%Show{categories: categories}), do: Enum.count(categories)

  def winning_categories(%Show{categories: categories}), do: Enum.filter(categories, fn category -> !is_nil(category.winner) end)

  def num_correct_voted_for_category(show, category, ballots) do
    Enum.count(ballots, fn %Ballot{votes: votes} ->
      case Enum.find(votes, fn vote -> vote.category.name == category.name end) do
        %Vote{contestant: contestant} -> contestant.name == category.winner.name
        _ -> false
      end
    end)
  end

  def percent_correct_voted_for_category(show, category, ballots) do
    num_ballots_with_vote_for_category = Enum.count(ballots, fn %Ballot{votes: votes} -> Enum.find(votes, fn vote -> vote.category.name == category.name end) end)
    num_ballots_with_correct_votes = num_correct_voted_for_category(show, category, ballots)

    if num_ballots_with_vote_for_category == 0 or num_ballots_with_correct_votes == 0 do
      "0.00"
    else
      div(num_ballots_with_correct_votes, num_ballots_with_vote_for_category) |> Kernel./(1) |> Float.round(2)
    end
  end

  def most_common_vote(show, %Category{contestants: contestants, name: category_name}, ballots) do
    frequency_map = Enum.frequencies_by(ballots, fn %Ballot{votes: votes} ->
      case Enum.find(votes, fn vote -> vote.category.name == category_name end) do
        %Vote{contestant: contestant} -> contestant.name
        _ -> :not_vote
      end
    end)
    |> Map.drop([:not_vote])
    |> Enum.max_by(fn {_, num_votes} -> num_votes end, &>=/2, fn -> {nil, nil} end)
  end

  def num_correct(ballot), do: Ballots.count_correct_votes(ballot)

end