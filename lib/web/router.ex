defmodule AwardsVoter.Web.Router do
  use AwardsVoter.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end
  
  pipeline :admin do
    plug :add_is_admin, true
  end
  
  pipeline :public do
    plug :add_is_admin, false
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/admin", AwardsVoter.Web do
    pipe_through :browser
    pipe_through :admin

    resources "/shows", ShowController, param: "name" do
      resources "/categories", CategoryController, param: "name", only: [:show, :new, :create] do
        resources "/contestants", ContestantController, param: "name", only: [:show, :new, :create]
      end
    end
  end
  
  scope "/", AwardsVoter.Web do
    pipe_through :browser
    pipe_through :public

    get "/", PageController, :index
  end
  
  defp add_is_admin(conn, bool) when is_boolean(bool) do
    assign(conn, :is_admin, bool)
  end
  
  defp add_is_admin(conn, _bool), do: assign(conn, :is_admin, false)
end
