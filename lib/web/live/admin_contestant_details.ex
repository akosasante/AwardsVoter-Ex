defmodule AwardsVoter.Web.AdminContestantDetails do
  use Phoenix.LiveComponent

  def render(%{contestant: contestant} = assigns) do
    IO.puts "RENDERING CONTESTANT LEEX: #{inspect contestant.name}"
    Phoenix.View.render(AwardsVoter.Web.AdminView, "contestant_details.html", assigns)
  end

end
