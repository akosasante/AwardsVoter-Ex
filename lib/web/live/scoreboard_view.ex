defmodule AwardsVoter.Web.ScoreboardView do
  use Phoenix.LiveView

  alias AwardsVoter.Context.Voting
  
  def render(assigns) do
    ~L"""
    <div><%= inspect @scores %></div>
    """
  end
  
  def mount(session, socket) do
    show_name = session["show_name"]
    if connected?(socket), do: AwardsVoter.Web.Endpoint.subscribe("ballots:#{URI.encode(show_name)}")
    scores = Voting.get_scores_for_show(show_name)
    {:ok, assign(socket, scores: scores)}
  end
  
  def handle_info(%{event: "update_scores", topic: "ballots:" <> show_name} = chanel, socket) do
    show_name = URI.decode(show_name)
    scores = Voting.get_scores_for_show(show_name)
    {:noreply, assign(socket, scores: scores)}
  end
end