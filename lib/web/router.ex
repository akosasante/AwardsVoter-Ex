defmodule AwardsVoter.Web.Router do
  use AwardsVoter.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/admin", AwardsVoter.Web do
    pipe_through :browser

    resources "/shows", ShowController, param: "name" do
      resources "/categories", CategoryController, param: "name", only: [:show] do
        resources "/contestants", ContestantController, param: "name", only: [:show]
      end
    end
  end
  
  scope "/", AwardsVoter.Web do
    pipe_through :browser

    get "/", PageController, :index
  end
  
end
