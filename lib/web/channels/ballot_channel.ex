defmodule AwardsVoter.Web.BallotChannel do
  use AwardsVoter.Web, :channel

  alias AwardsVoter.Context.Voting

  def join("ballots:" <> _show_name, _payload, socket) do
    {:ok, socket}
  end

  def handle_in("get_scores", %{"show_name" => show_name}, socket) do
    show_name_decoded = URI.decode(show_name)
    scores = Voting.get_scores_for_show(show_name_decoded)
             |> Enum.map(&Tuple.to_list/1)
    {:reply, {:ok, %{scores: scores}}, socket}
  end
end