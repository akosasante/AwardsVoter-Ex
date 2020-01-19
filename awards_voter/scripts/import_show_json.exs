defmodule ShowImporter do
  alias AwardsVoter.{Show, ShowManager}
  # Note: this script must be started in --no-start mode. Since we need the 
  # supervision tree for the ShowManager start_link to match up with the calling script
  
  def parse_json(json_path) do
    parsed_show = File.read!(json_path)
    |> Jason.decode!(keys: :atoms)
    
    {:ok, show} = Show.new(parsed_show.name, parsed_show.categories)
    show
  end
  
  def save(shows) do
    ShowManager.start_link(:ok)
    Show.save_or_update_shows(shows)
    :dets.close(:shows)
  end
end

System.argv()
|> Kernel.hd
|> ShowImporter.parse_json
|> ShowImporter.save
|> IO.inspect