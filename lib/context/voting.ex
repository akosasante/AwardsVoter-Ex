defmodule AwardsVoter.Context.Voting do
  alias __MODULE__
  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Voting.Votes
  alias AwardsVoter.Context.Voting.Ballots
  alias AwardsVoter.Context.Voting.Ballots.Ballot
  alias AwardsVoter.Context.Voting.Votes.Vote
  alias AwardsVoter.Context.Admin.Categories.Category
  
  require Logger

  defdelegate change_ballot(ballot), to: Ballots
  defdelegate save_ballot(ballot, show_name), to: Ballots
  def get_ballot_for(username, show_name), do: Ballots.get_ballot_by_username_and_show(username, show_name)
  
  @spec create_new_ballot(String.t(), Show.t()) :: Ballots.change_result() | :error
  def create_new_ballot(username, show_name) do
    with {:show, {:ok, show}} <- {:show, Admin.get_show_by_name(show_name)},
         {:create_ballot, {:ok, ballot}} <- {:create_ballot, Ballots.create_ballot_from_show_or_categories(username, show)},
         {:saved_ballot, {:ok, saved_ballot}} <- {:saved_ballot, Ballots.save_ballot(ballot, show_name)} do
      {:ok, saved_ballot}
    else
      {:show, e} -> 
        Logger.error("Error getting show (#{inspect show_name}, #{inspect e}")
        :error
      {:create_ballot, e} -> 
        Logger.error("Error creating ballot: #{inspect e}")
        e
      {:saved_ballot, e} ->
        Logger.error("Error saving ballot: #{inspect e}")
        :error
    end
  end
  
  @spec vote(Ballot.t(), String.t(), String.t()) :: {:ok | :invalid_vote, Ballot.t()}
  def vote(ballot, category_name, contestant_name) do
    with {:get_category_vote, %Vote{} = category_vote_entry} <- {:get_category_vote, Ballots.get_vote_by_category(ballot, category_name)},
         {:do_vote, {:ok, vote}} <- {:do_vote, vote(category_vote_entry, contestant_name)},
         {:update_ballot, {:ok, updated_ballot}} <- {:update_ballot, Ballots.update_ballot_with_vote(ballot, vote)}
      do
      {:ok, updated_ballot}
    else
      {:get_category_vote, nil} ->
        Logger.error("Category (#{category_name}) does not exist in ballot")
        {:invalid_vote, ballot}
      {:do_vote, _} ->
        Logger.error("Invalid or nil argument passed to Voting.vote/2")
        {:invalid_vote, ballot}
      {:update_ballot, e} ->
        Logger.error("Error raised when trying to update ballot: #{inspect e}")
        {:invalid_vote, ballot}
    end
  end

  @spec vote(Vote.t(), String.t()) :: :invalid_category | {:ok, Vote.t()} | {:invalid_vote, Vote.t()}
  def vote(nil, _), do: :error
  def vote(vote, contestant_name) do
    case Enum.find(vote.category.contestants, nil, fn contestant ->
      contestant.name == contestant_name
    end) do
      nil -> {:invalid_vote, vote}
      cont -> {:ok, %{vote | contestant: cont}}
    end
  end
  
  def multi_vote(ballot, vote_map) do
    Enum.reduce(vote_map, {:ok, ballot}, fn {category, contestant}, {:ok, updated_ballot} ->
      vote(updated_ballot, category, contestant)
    end)
  end

  @spec is_winning_vote?(Vote.t()) :: boolean()
  def is_winning_vote?(%Vote{contestant: nil}), do: false
  def is_winning_vote?(%Vote{category: nil}), do: false
  def is_winning_vote?(%Vote{category: %Category{winner: nil}}), do: false
  def is_winning_vote?(vote) do
    vote.contestant.name == vote.category.winner.name
  end

  @spec score(Ballot.t()) :: {:ok, non_neg_integer()}
  def score(ballot) do
    {:ok, Enum.count(ballot.votes, &is_winning_vote?/1)}
  end
  
  def get_scores_for_show(show_name) do
    show_name
    |> Ballots.list_ballots_for_show()
    |> Enum.map(fn ballot -> 
      {:ok, score} = score(ballot) 
      {ballot.voter, score}
    end)
  end
  
  def update_ballots_for_show(show) do
    show.name
    |> Ballots.list_ballots_for_show()
    |> Enum.map(fn ballot -> Ballots.update_ballot_with_winners(ballot, show.categories) end)
    |> Enum.each(fn
      {:ok, updated_ballot} -> save_ballot(updated_ballot, show.name)
      {:errors, e} -> Logger.error("Unable to update ballot: #{inspect e}")
    end)
    :ok
  end
end