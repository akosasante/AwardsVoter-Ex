defmodule AwardsVoter.Web.ContestantController do
  use AwardsVoter.Web, :controller

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Admin.Shows
  alias AwardsVoter.Context.Admin.Contestants
  alias AwardsVoter.Context.Admin.Contestants.Contestant

  require Logger
  
  def show(conn, %{"show_name" => show_name, "category_name" => category_name, "name" => name}) do
    with {:ok, show} <- Shows.get_show_by_name(show_name),
         category <- Enum.find(show.categories, fn cat -> cat.name == category_name end),  # %Category{} = category <-
         contestant <- Enum.find(category.contestants, fn cont -> cont.name == name end) do  # %Contestant{} = contestant <-
      render(conn, "show.html", contestant: contestant, show_name: show_name, category_name: category_name)
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
  
  def new(conn, %{"show_name" => show_name, "category_name" => category_name}) do
    changeset = Contestants.change_category(%Contestant{})
    render(conn, "new.html", changeset: changeset, options: [], show_name: show_name, category_name: category_name)
  end
  
  def create(conn, %{"show_name" => show_name, "category_name" => category_name, "contestant" => contestant_params}) do
    case Admin.add_contestant_to_show_category(show_name, category_name, contestant_params) do
      {:ok, show} -> 
        conn
        |> put_flash(:info, "Contestant added successfully")
        |> redirect(to: Routes.show_category_path(conn, :show, show_name, category_name))
      {:errors, %Ecto.Changeset{} = changeset} -> render(conn, "new.html", changeset: changeset, options: [])
    end
  end
end