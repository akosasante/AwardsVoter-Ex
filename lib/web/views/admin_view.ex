defmodule AwardsVoter.Web.AdminView do
  use AwardsVoter.Web, :admin_view

  alias AwardsVoter.Context.Admin

  def render_view_page(page_name, assigns), do: render("view_show/#{page_name}", assigns)
  def render_edit_page(page_name, assigns), do: render("edit_show/#{page_name}", assigns)

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

  def is_winner(category, contestant) do
    winner = Map.get(category, :winner, nil)

    if !is_nil(winner) and Map.has_key?(category.winner, :name) do
      category.winner.name == contestant.name
    else
      false
    end
  end

  def trim_for_id(value), do: String.replace(value, " ", "")

  def get_category(show, category_name), do: Admin.get_category_by_name(show, category_name)
end
