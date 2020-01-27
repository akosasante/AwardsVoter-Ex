defmodule ShowImporter do
  alias AwardsVoter.Context.Admin.Shows
  alias AwardsVoter.Context.Admin.Shows.ShowManager
  
  def parse_json(json_path) do
    File.read!(json_path)
    |> Jason.decode!(keys: :atoms)
  end
  
  def save(show) do
    _pid = ShowManager.start_link(:ok)
    Shows.create_show(show)
    :dets.close(:shows) # can we just kill showmanager?
  end
end

System.argv()
|> Kernel.hd
|> ShowImporter.parse_json
|> ShowImporter.save
|> IO.inspect