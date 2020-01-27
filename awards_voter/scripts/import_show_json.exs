defmodule ShowImporter do
  alias AwardsVoter.Show
  
  def parse_json(json_path) do
    parsed_show = File.read!(json_path)
    |> Jason.decode!(keys: :atoms)
    
    {:ok, show} = Show.new(parsed_show.name, parsed_show.categories)
    show
  end
  
  def save(shows) do
    :dets.open_file(:shows, [])
    Show.save_or_update_shows(shows)
#    |> IO.inspect
    :dets.close(:shows)
  end
end

System.argv()
|> Kernel.hd
|> ShowImporter.parse_json
|> ShowImporter.save
|> IO.inspect