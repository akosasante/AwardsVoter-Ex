defmodule AwardsVoter.Web.BallotNew do
  use AwardsVoter.Web, :live_view

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Ballots
  alias AwardsVoter.Web.Router.Helpers, as: Routes

  require Logger

  def render(assigns) do
    AwardsVoter.Web.BallotView.render("new_ballot.html", assigns)
  end

  def mount(%{"show_id" => show_id}, _session, socket) do
    socket = assign_new(socket, :show, fn -> Admin.get_show_by_id(show_id) end)
    socket = assign_new(socket, :ballot_changeset, fn -> Ballots.new_ballot() end)
    {:ok, socket}
  end

  def handle_event("submit_new_ballot", %{"ballot_voter" => ballot_name, "userId" => user_id}, %{assigns: %{show: show}} = socket) do
    {ballot_type, ballot} = case Ballots.find_ballot_by_voter_and_show(user_id, show.id) do
      nil ->
        if String.length(ballot_name) > 0 do
          {:new, Ballots.create_ballot(%{"voter" => user_id, "show_id" => show.id, "ballot_name" => ballot_name})}
        else
          {:blank_ballot_name, nil}
        end

      ballot -> {:existing, ballot}
    end

    socket = if ballot_type == :blank_ballot_name do
      put_flash(socket, :error, "Newly created ballots need a name, please")
    else
      flash = case ballot_type do
        :new -> "Ballot created successfully."
        :existing -> "Existing ballot opened."
      end

      socket
      |> put_flash(:info, flash)
      |> push_redirect(to: Routes.ballot_path(socket, :get_ballot, ballot.id))
    end

    {:noreply, socket}
  end

  def handle_event("submit_new_ballot", %{"errorMessage" => errMessage, "errorCode" => errCode}, %{assigns: %{show: show}} = socket) do
    Logger.error("Error when submiting a new ballot: code=#{errCode} message=#{errMessage}")

    socket = socket
             |> put_flash(:error, errMessage)
    {:noreply, socket}
  end
end
