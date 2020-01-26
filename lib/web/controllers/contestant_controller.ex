defmodule AwardsVoter.Web.ContestantController do
  use AwardsVoter.Web, :controller

  alias AwardsVoter.Context.Admin.Shows

  require Logger
  
  def show(conn, %{"show_name" => show_name, "category_name" => category_name, "name" => name}) do
    with {:ok, show} <- Shows.get_show_by_name(show_name),
         category <- Enum.find(show.categories, fn cat -> cat.name == category_name end),  # %Category{} = category <-
         contestant <- Enum.find(category.contestants, fn cont -> cont.name == name end) do  # %Contestant{} = contestant <-
      render(conn, "show.html", contestant: contestant)
    else
      nil -> Logger.error("Couldn't find category (#{category_name}) or contestant (#{name}) on show (#{show_name})")
             conn
             |> put_flash(:error, "Couldn't find category (#{category_name}) or contestant (#{name})")
             |> redirect(to: Routes.show_category_path(conn, :show, show_name, category_name))
      e -> Logger.error("Error during Shows.get_show_by_name: #{inspect e}")
             conn
             |> put_flash(:error, "Could't find show (#{show_name})")
             |> redirect(to: Routes.show_path(conn, :index))
    end
  end
end