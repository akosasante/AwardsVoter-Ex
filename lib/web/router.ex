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
      resources "/categories", CategoryController, param: "name", except: [:index] do
        resources "/contestants", ContestantController, param: "name", except: [:index]
      end
    end
    put "/shows/:show_name/categories/:category_name/set_winner/:contestant_name", CategoryController, :set_winner
  end
  
  scope "/", AwardsVoter.Web do
    pipe_through :browser
    pipe_through :public

    get "/", PageController, :index
    
    get "/ballot/:show_name/new", BallotController, :new
    get "/ballot/:show_name/continue", BallotController, :continue
    post "/ballot/:show_name", BallotController, :create
    get "/ballot/:show_name/:voter_name", BallotController, :show
    get "/ballot/:show_name/:voter_name/edit", BallotController, :edit
    put "/ballot/:show_name/:voter_name", BallotController, :update
  end
  
  defp add_is_admin(conn, bool) when is_boolean(bool) do
    assign(conn, :is_admin, bool)
  end
  
  defp add_is_admin(conn, _bool), do: assign(conn, :is_admin, false)
end
