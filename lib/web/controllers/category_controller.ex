defmodule AwardsVoter.Web.CategoryController do
  use AwardsVoter.Web, :controller

  alias AwardsVoter.Context.Admin.Shows
  alias AwardsVoter.Context.Admin.Categories.Category

  require Logger
  
  def show(conn, %{"show_name" => show_name, "name" => name}) do
    with {:ok, show} <- Shows.get_show_by_name(show_name),
         category <- Enum.find(show.categories, fn cat -> cat.name == name end) do  # %Category{} = category <-
      render(conn, "show.html", category: category, show_name: show_name, is_admin: true)
    else
      nil -> Logger.error("Couldn't find category (#{name}) on show (#{show_name})")
             conn 
             |> put_flash(:error, "Couldn't find category (#{name})") 
             |> redirect(to: Routes.show_path(conn, :index))
      e -> Logger.error("Error during Shows.get_show_by_name: #{inspect e}")
             conn
             |> put_flash(:error, "Could't find show (#{show_name})")
             |> redirect(to: Routes.show_path(conn, :index))
    end
  end
end