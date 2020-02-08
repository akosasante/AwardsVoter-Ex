defmodule AwardsVoter.Web.BallotController do
  use AwardsVoter.Web, :controller
  
  alias AwardsVoter.Context.Voting
  alias AwardsVoter.Context.Voting.Ballots.Ballot
  
  require Logger
  
  def new(conn, %{"show_name" => show_name}) do
    changeset = Voting.change_ballot(%Ballot{})
    render(conn, "new.html", changeset: changeset, options: [], show_name: show_name)
  end
  
  def continue(conn, %{"show_name" => show_name}) do
    changeset = Voting.change_ballot(%Ballot{})
    render(conn, "continue.html", changeset: changeset, options: [], show_name: show_name)
  end
  
  def validate_continue(conn, %{"show_name" => show_name, "ballot" => %{"username" => username}}) do
    case Voting.get_ballot_for(username, show_name) do
      {:ok, ballot} -> redirect(conn, to: Routes.ballot_path(conn, :edit, show_name, username))
      :not_found -> 
        conn
        |> put_flash(:error, "Username not found, please try again.")
        |> redirect(to: Routes.ballot_path(conn, :continue, show_name))
      e -> 
        Logger.error("Could not validate continue_ballot step: #{inspect e}")
        conn
        |> put_flash(:error, "Something went wrong when attempting to fetch ballot")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end
  
  def create(conn, %{"ballot" => %{"username" => username}, "show_name" => show_name}) do
    case Voting.create_new_ballot(username, show_name) do
      {:ok, ballot} ->
        conn
        |> redirect(to: Routes.ballot_path(conn, :edit, show_name, username))
      {:errors, %Ecto.Changeset{} = changeset} -> render(conn, "new.html", changeset: changeset, options: [])
    end
  end
  
  def show(conn, %{"show_name" => show_name, "voter_name" => voter_name}) do
    case Voting.get_ballot_for(voter_name, show_name) do
      {:ok, ballot} -> render(conn, "show.html", ballot: ballot, show_name: show_name)
      e ->
        Logger.error("Error during Voting.get_ballot_for(#{inspect e})")
        conn
        |> put_flash(:error, "Could not create new ballot.")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end
  
  def edit(conn, %{"show_name" => show_name, "voter_name" => voter_name}) do
    case Voting.get_ballot_for(voter_name, show_name) do
      {:ok, ballot} -> 
        changeset = Voting.change_ballot(ballot)
        render(conn, "edit.html", changeset: changeset, show_name: show_name, options: [method: "put"])
      e ->
        Logger.error("Error during Voting.get_ballot_for(#{inspect e})")
        conn
        |> put_flash(:error, "Error getting ballot")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end
  
  def update(conn, %{"ballot" => vote_map, "voter_name" => voter_name, "show_name" => show_name}) do
    case Voting.get_ballot_for(voter_name, show_name) do
      {:ok, ballot} -> 
        {:ok, updated_ballot} = Voting.multi_vote(ballot, vote_map)
        {:ok, saved_ballot} = Voting.save_ballot(updated_ballot, show_name)
        redirect(conn, to: Routes.ballot_path(conn, :show, show_name, voter_name))
      e -> 
        Logger.error("Error during updating ballot #{inspect e}")
        conn
        |> put_flash(:error, "Something went wrong when saving your ballot :(")
        |> redirect(to: Routes.ballot_path(conn, :index))
    end
  end
  
  def scoreboard(conn, %{"show_name" => show_name}) do
    scores = Voting.get_scores_for_show(show_name)
    render(conn, "scoreboard.html", scores: scores, show_name: show_name)
  end
end