defmodule AwardsSite.Shows do
  alias AwardsSite.Models.{Show}
  
  def list_shows do
    [
      %Show{name: "2019 Grammy Awards", categories: []},
      %Show{name: "2019 Screen Actors Guild Awards", categories: []},
      %Show{name: "2019 Academy Awards", categories: []}
    ]
  end
  
  def get_show_by(params) do
    Enum.find(list_shows(), fn map ->
      Enum.all?(params, fn {key, val} -> Map.get(map, key) == val end)
    end)
  end
end