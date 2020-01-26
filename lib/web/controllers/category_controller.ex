defmodule AwardsVoter.Web.CategoryController do
  use AwardsVoter.Web, :controller

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Admin.Shows
  alias AwardsVoter.Context.Admin.Categories
  alias AwardsVoter.Context.Admin.Categories.Category

  require Logger
  
  def show(conn, %{"show_name" => show_name, "name" => name}) do
    with {:ok, show} <- Shows.get_show_by_name(show_name),
         category <- Enum.find(show.categories, fn cat -> cat.name == name end) do  # %Category{} = category <-
      render(conn, "show.html", category: category, show_name: show_name)
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
  
  def new(conn, %{"show_name" => show_name}) do
    changeset = Categories.change_category(%Category{})
    render(conn, "new.html", changeset: changeset, options: [], show_name: show_name)
  end
  
  def create(conn, %{"category" => category_params, "show_name" => show_name}) do
    case Admin.add_category_to_show(show_name, category_params) do
      {:ok, show} -> 
        conn
        |> put_flash(:info, "Category added successfully")
        |> redirect(to: Routes.show_path(conn, :show, show_name))
      {:errors, %Ecto.Changeset{} = changeset} -> render(conn, "new.html", changeset: changeset, options: [])
    end
  end
end