defmodule AwardsVoter.Web.BallotController do
  use AwardsVoter.Web, :controller
  
  require Logger
  
  def new(conn, %{"show_name" => show_name}) do
    render(conn, "new.html", show_name: show_name)
  end
  
  def continue do
    
  end
  
  def create do
    
  end
  
  def show do
    
  end
  
  def edit do
    
  end
  
  def update do
    
  end
end