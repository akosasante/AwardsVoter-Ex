defmodule AwardsVoter.Web.BallotView do
  use AwardsVoter.Web, :view

  alias AwardsVoter.Context.Models.Vote

  def is_matching_contestant(vote_map, category, contestant) do
    Map.get(vote_map, category.name) == contestant.name
  end

  def get_voted_for_contestant(ballot, category) do
    case Enum.find(ballot.votes, fn vote -> vote.category.name == category.name end) do
      nil -> %{}
      vote_for_category -> Map.get(vote_for_category, :contestant, nil)
    end
  end

  def has_vote?(category, vote_map, ballot) do
    in_vote_map = category.name in Map.keys(vote_map)
    in_ballot = category.name in Enum.map(ballot.votes, fn %Vote{category: category} -> category.name end)
    in_vote_map or in_ballot
  end

  def format_datetime_string(datetime_string) do
    {:ok, datetime, _utc_offset} = DateTime.from_iso8601(datetime_string <> ":00Z")
    %DateTime{year: year, month: month, day: day, hour: hour, minute: minute} = datetime
    time = if hour > 12 do
      "#{hour - 12}:#{minute}PM"
    else
      "#{hour}:#{minute}AM"
    end
    "#{day}/#{month}/#{year} at #{time}"
  end

  def format_youtube_url(youtube_url) do
    if String.contains?(youtube_url, "/embed") do
      youtube_url
    else
      [video_id] = Regex.run(~r/watch\?v=(.*)/, youtube_url, capture: :all_but_first)
      "https://www.youtube.com/embed/#{video_id}"
    end
  end

  def format_spotify_url(spotify_url) do
    if String.contains?(spotify_url, "/embed") do
      spotify_url
    else
      [base_url, spotify_id] = String.split(spotify_url, "track")
      "#{base_url}embed/track#{spotify_id}"
    end
  end
end
