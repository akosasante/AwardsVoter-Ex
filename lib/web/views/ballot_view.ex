defmodule AwardsVoter.Web.BallotView do
  use AwardsVoter.Web, :view

  def render_vote_options(form, vote) do
    ~E"""
      <%= for contestant <- vote.category.contestants do %>
        <%= label do %>
        <span><%= contestant.name %></span>
        <%= radio_button form, String.to_atom(vote.category.name), contestant.name, checked: contestant.name == get_in(vote.contestant, [:name]) %>
      <% end %>
      <% end %>
    """
  end
end