defmodule AwardsVoter.Web.AdminView do
  use AwardsVoter.Web, :view

  def format_datetime_string(datetime_string) do
    {:ok, datetime, _utc_offset} = DateTime.from_iso8601(datetime_string)
    %DateTime{year: year, month: month, day: day, hour: hour, minute: minute} = datetime
    "#{day}/#{month}/#{year} at #{hour}:#{minute}"
  end
end
