defmodule AwardsVoter.Web.Router do
  use Phoenix.Router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AwardsVoter.Web.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/admin", AwardsVoter.Web do
    pipe_through :browser
    
    get "/", AdminController, :admin_index
    get "/shows", AdminController, :list_shows
    get "/shows/:id", AdminController, :get_show
    live "/shows/:id/edit", AdminShowEdit
    delete "/shows/:id", AdminController, :delete_show
    post "/shows/json", AdminController, :upload_show_json
  end

  scope "/", AwardsVoter.Web do
    pipe_through :browser

    get "/", BallotController, :home
    get "/ballots/:show_id/new", BallotController, :new_ballot
    post "/ballots", BallotController, :create_ballot
    get "/ballots/:id", BallotController, :get_ballot
    live "/ballots/:id/edit", BallotEdit
  end

  # Other scopes may use custom stacks.
  # scope "/api", AwardsVoter.Web do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: AwardsVoter.Web.Telemetry
    end
  end
end
