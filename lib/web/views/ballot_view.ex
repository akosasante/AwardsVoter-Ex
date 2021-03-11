defmodule AwardsVoter.Web.BallotView do
  use AwardsVoter.Web, :view

  alias AwardsVoter.Context.Models.Vote
  alias AwardsVoter.Context.Models.Show

  @buffer_airdate_duration 60 * 10 # users can still enter their votes up to 10 minutes after the starting time of the show

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
    {:ok, %DateTime{year: year, month: month, day: day, hour: hour, minute: minute}} = DateTime.from_naive(datetime, "America/Toronto", Tz.TimeZoneDatabase)
    time = if hour > 12 do
      "#{hour - 12}:#{String.pad_leading("#{minute}", 2, "0")}PM"
    else
      "#{hour}:#{String.pad_leading("#{minute}", 2, "0")}AM"
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

  def airtime_is_valid(%Show{air_datetime: nil}), do: true

  def airtime_is_valid(%Show{air_datetime: air_datetime}) do
    {:ok, datetime, _utc_offset} = DateTime.from_iso8601(air_datetime <> ":00Z")
    {:ok, datetime_est} = DateTime.from_naive(datetime, "America/Toronto", Tz.TimeZoneDatabase)
    {:ok, now} = DateTime.now("America/Toronto", Tz.TimeZoneDatabase)
    DateTime.diff(now, datetime_est) <= @buffer_airdate_duration
  end

  def comparison_bg_color(category, ballot, other_ballot) do
    voted_for = get_voted_for_contestant(ballot, category)

    cond do
      is_nil(category.winner) and !is_nil(Map.get(voted_for, :name)) and is_unique_vote?(category, ballot, other_ballot) -> "bg-yellow-200"
      is_nil(category.winner) -> "bg-white"
      Map.get(voted_for, :name) == category.winner.name -> "bg-green-300"
      true -> "bg-red-300"
    end
  end

  defp is_unique_vote?(category, ballot, other_ballot) do
    ballot_1_voted_for = get_voted_for_contestant(ballot, category)
    ballot_2_voted_for = get_voted_for_contestant(other_ballot, category)

    Map.get(ballot_1_voted_for, :name) != Map.get(ballot_2_voted_for, :name)
  end
end
