defmodule AwardsVoter.Web.ContestantController do
  use AwardsVoter.Web, :controller

  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Admin.Shows
  alias AwardsVoter.Context.Admin.Categories.Category
  alias AwardsVoter.Context.Admin.Contestants
  alias AwardsVoter.Context.Admin.Contestants.Contestant

  require Logger
  
  def show(conn, %{"show_name" => show_name, "category_name" => category_name, "name" => name}) do
    case Admin.get_contestant_from_show(show_name, category_name, name) do
      {:ok, contestant} -> render(conn, "show.html", contestant: contestant, show_name: show_name, category_name: category_name)
      category_not_found -> Logger.error("Couldn't find category (#{category_name}) on show (#{show_name})")
                            conn
                            |> put_flash(:error, "Couldn't find category (#{category_name})")
                            |> redirect(to: Routes.show_category_path(conn, :show, show_name, category_name))
      contestant_not_found -> Logger.error("Couldn't find contestant (#{name}) on show (#{show_name}), category (#{category_name})")
                            conn
                            |> put_flash(:error, "Couldn't find contestant (#{name})")
                            |> redirect(to: Routes.show_category_path(conn, :show, show_name, category_name))
    end
  end
  
  def new(conn, %{"show_name" => show_name, "category_name" => category_name}) do
    changeset = Contestants.change_contestant(%Contestant{})
    render(conn, "new.html", changeset: changeset, options: [], show_name: show_name, category_name: category_name)
  end
  
  def create(conn, %{"show_name" => show_name, "category_name" => category_name, "contestant" => contestant_params}) do
    case Admin.add_contestant_to_show_category(show_name, category_name, contestant_params) do
      {:ok, _show} -> 
        conn
        |> put_flash(:info, "Contestant added successfully")
        |> redirect(to: Routes.show_category_path(conn, :show, show_name, category_name))
      {:errors, %Ecto.Changeset{} = changeset} -> render(conn, "new.html", changeset: changeset, options: [])
    end
  end
  
  def edit(conn, %{"show_name" => show_name, "category_name" => category_name, "name" => name}) do
    case Admin.get_contestant_from_show(show_name, category_name, name) do
      {:ok, contestant} -> changeset = Contestants.change_contestant(contestant)
                           render(conn, "edit.html", show_name: show_name, category_name: category_name, contestant_name: name, changeset: changeset, options: [method: "put"])
    end
  end
  
  def update(conn, %{"show_name" => show_name, "category_name" => category_name, "name" => name, "contestant" => contestant_params}) do
    case Admin.update_contestant_in_show_category(show_name, category_name, name, contestant_params) do
      {:ok, _show} ->
        conn
        |> put_flash(:info, "Contestant updated successfully")
        |> redirect(to: Routes.show_category_contestant_path(conn, :show, show_name, category_name, contestant_params["name"]))
      {:errors, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", show_name: show_name, category_name: category_name, contestant_name: name, changeset: changeset, options: [method: "put"])
    end
  end

  def delete(conn, %{"show_name" => show_name, "category_name" => category_name, "name" => name}) do
    case Admin.delete_contestant_from_show_category(show_name, category_name, name) do
      {:ok, _show} -> 
        conn 
        |> put_flash(:info, "Contestant deleted successfully.") 
        |> redirect(to: Routes.show_category_path(conn, :show, show_name, category_name))
    end
  end
end