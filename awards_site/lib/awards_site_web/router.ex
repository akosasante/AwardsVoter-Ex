defmodule AwardsSiteWeb.Router do
  use AwardsSiteWeb, :router

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

  scope "/", AwardsSiteWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

   scope "/admin", AwardsSiteWeb do
     pipe_through :browser
     resources "/shows", ShowController
     resources "/categories", CategoryController
  end
end
