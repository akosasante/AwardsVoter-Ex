defmodule AwardsVoter.Web.AdminShowDetails do
  use Phoenix.LiveView

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Models.Show

  def render(assigns) do
    IO.puts "RENDERING SHOW LEEX"
    Phoenix.View.render(AwardsVoter.Web.AdminView, "show_details.html", assigns)
  end

  def mount(params, %{"show_id" => show_id}, socket) do
    IO.puts "MOUNTING SHOW"
    socket = assign_new(socket, :show, fn ->
      case Admin.get_show_by_id(show_id) do
        %Show{} = show -> show
        e -> nil
      end
    end)
    {:ok, socket}
  end
end
