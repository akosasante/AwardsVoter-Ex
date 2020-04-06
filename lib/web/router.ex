defmodule AwardsVoter.Web.Router do
  use AwardsVoter.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_is_admin
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/admin", AwardsVoter.Web do
    pipe_through :browser

    resources "/shows", ShowController, param: "name" do
      resources "/categories", CategoryController, param: "name", except: [:index] do
        resources "/contestants", ContestantController, param: "name", except: [:index]
      end
    end
    post "/shows/show_json", ShowController, :create_json
    put "/shows/:show_name/categories/:category_name/set_winner/:contestant_name", CategoryController, :set_winner, as: :show_category
  end

  scope "/", AwardsVoter.Web do
    pipe_through :browser

    get "/", PageController, :index

    get "/ballot/:show_name/new", BallotController, :new
    get "/ballot/:show_name/continue", BallotController, :continue
    post "/ballot/:show_name/validate_continue", BallotController, :validate_continue
    get "/ballot/:show_name/scoreboard", BallotController, :scoreboard
    post "/ballot/:show_name", BallotController, :create
    get "/ballot/:show_name/:voter_name", BallotController, :show
    get "/ballot/:show_name/:voter_name/edit", BallotController, :edit
    put "/ballot/:show_name/:voter_name", BallotController, :update
  end

  defp put_is_admin(conn, _opts) do
    is_admin_path = Enum.find(conn.path_info, fn x -> x == "admin" end)
    if is_admin_path do
      assign(conn, :is_admin, true)
    else
      assign(conn, :is_admin, false)
    end
  end
end
