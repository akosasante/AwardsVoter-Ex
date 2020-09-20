defmodule AwardsVoter.Web.BallotView do
  use AwardsVoter.Web, :view

  def render_vote_options(form, vote, linker) do
    contestant_name = case vote.contestant do
      nil -> nil
      c -> c.name
    end
    ~E"""
      <%= for contestant <- vote.category.contestants do %>
        <%= label style: 'display: block', class: 'm-2' do %>
        <%= radio_button form, String.to_atom(vote.category.name), contestant.name, checked: contestant.name == contestant_name %>
        <span><%= contestant.name %></span>
        <span class="mx-5 underline"><%= linker.(contestant.name) %></span>
      <% end %>
      <% end %>
    """
  end
end
