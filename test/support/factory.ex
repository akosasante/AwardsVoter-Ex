defmodule AwardsVoter.Factory do
  @moduledoc """
  Used to create test fixtures.
  """
  use ExMachina.Ecto

  alias AwardsVoter.Context.Models.Contestant
  alias AwardsVoter.Context.Models.Category
  alias AwardsVoter.Context.Models.Show
  alias AwardsVoter.Context.Models.Vote
  alias AwardsVoter.Context.Models.Ballot

  def contestant_factory do
    %Contestant{
      name: sequence(:contestant_name, &"Contestant##{&1}"),
      description: "test contestant description. #{lorem_ipsum()}",
      image_url: "https://via.placeholder.com/250",
      youtube_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      spotify_url:
        "https://open.spotify.com/playlist/37i9dQZF1DX6cg4h2PoN9y?si=znVkhu3RT5-kCKjaUUmB7g",
      wiki_url: "https://en.wikipedia.org/wiki/Curb_Your_Enthusiasm",
      billboard_stats: "Hot 100: 17/8, Hot Rock: 17/8"
    }
  end

  def category_factory(opts) do
    has_winner = Map.get(opts, :has_winner, false)
    contestants = build_list(4, :contestant)

    category = %Category{
      name: sequence(:category_name, &"Category##{&1}"),
      description: "test category description. #{lorem_ipsum()}",
      contestants: contestants
    }

    if has_winner do
      struct!(category, winner: Enum.random(contestants))
    else
      category
    end
  end

  def show_factory do
    categories = build_list(4, :category)

    %Show{
      name: sequence(:show_name, &"Show##{&1}"),
      description: "test show description. #{lorem_ipsum()}",
      air_datetime: "2020-09-23 22:36:58.737215Z",
      categories: categories
    }
  end

  def vote_factory do
    %Vote{
      category: build(:category),
      contestant: build(:contestant)
    }
  end

  def ballot_factory do
    votes = build_list(5, :vote)

    %Ballot{
      voter: sequence(:ballot_voter, &"Ballot##{&1}"),
      votes: votes
    }
  end

  defp lorem_ipsum(),
    do:
      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."
end
