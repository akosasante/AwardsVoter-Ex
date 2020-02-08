defmodule AwardsVoter.Web.BallotController do
  use AwardsVoter.Web, :controller
  
  alias AwardsVoter.Context.Voting
  alias AwardsVoter.Context.Voting.Ballots.Ballot
  
  require Logger
  
  def new(conn, %{"show_name" => show_name}) do
    changeset = Voting.change_ballot(%Ballot{})
    render(conn, "new.html", changeset: changeset, options: [], show_name: show_name)
  end
  
  def continue do
    
  end
  
  def create(conn, %{"ballot" => %{"username" => username}, "show_name" => show_name}) do
    case Voting.create_new_ballot(username, show_name) do
      {:ok, ballot} ->
        conn
        |> redirect(to: Routes.ballot_path(conn, :show, show_name, username))
      {:errors, %Ecto.Changeset{} = changeset} -> render(conn, "new.html", changeset: changeset, options: [])
    end
  end
  
  def show(conn, %{"show_name" => show_name, "voter_name" => voter_name}) do
    case Voting.get_ballot_for(voter_name) do
      {:ok, ballot} -> render(conn, "show.html", ballot: ballot, show_name: show_name)
      e ->
        Logger.error("Error during Voting.get_ballot_for(#{inspect e})")
        conn
        |> put_flash(:error, "Could not create new ballot.")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end
  
  def edit(conn, %{"show_name" => show_name, "voter_name" => voter_name}) do
    case Voting.get_ballot_for(voter_name) do
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
    case Voting.get_ballot_for(voter_name) do
      {:ok, ballot} -> 
        {:ok, updated_ballot} = Voting.multi_vote(ballot, vote_map)
        {:ok, saved_ballot} = Voting.save_ballot(updated_ballot)
        render(conn, "show.html", ballot: ballot, show_name: show_name)
      e -> 
        Logger.error("Error during update #{inspect e}")
        render(conn, "index.html")
    end
    :ok
  end
end