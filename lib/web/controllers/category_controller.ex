defmodule AwardsVoter.Web.CategoryController do
  use AwardsVoter.Web, :controller

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Admin.Shows
  alias AwardsVoter.Context.Admin.Categories
  alias AwardsVoter.Context.Admin.Categories.Category

  require Logger
  
  def show(conn, %{"show_name" => show_name, "name" => name}) do
    case Admin.get_category_from_show(show_name, name) do
      {:ok, category} -> render(conn, "show.html", category: category, show_name: show_name)
      :category_not_found -> Logger.error("Couldn't find category (#{name}) on show (#{show_name})")
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
  
  def edit(conn, %{"show_name" => show_name, "name" => name}) do
    case Admin.get_category_from_show(show_name, name) do
      {:ok, category} -> changeset = Categories.change_category(category)
                         render(conn, "edit.html", show_name: show_name, category_name: name, changeset: changeset, options: [method: "put"])
    end
  end
  
  def update(conn, %{"show_name" => show_name, "name" => name, "category" => category_params}) do
    case Admin.update_show_category(show_name, name, category_params) do
      {:ok, _show} ->
        conn
        |> put_flash(:info, "Category updated successfully")
        |> redirect(to: Routes.show_category_path(conn, :show, show_name, category_params["name"]))
      {:errors, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", show_name: show_name, category_name: name, changeset: changeset, options: [method: "put"])
    end
  end
  
  def delete(conn, %{"show_name" => show_name, "name" => name}) do
    case Admin.delete_show_category(show_name, name) do
      {:ok, _show} ->
        conn
        |> put_flash(:info, "Contestant deleted successfully.")
        |> redirect(to: Routes.show_path(conn, :show, show_name))
    end
  end
end