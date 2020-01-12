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
     
     get "/shows", AdminController, :index # List all available award shows
     get "/shows/:id", AdminController, :show # Details of a particular award show
     put "/shows/:id", AdminController, :upsert # Update or create a particular award show
     delete "/shows/:id", AdminController, :delete # Delete the data for a particular award show
   end
end
