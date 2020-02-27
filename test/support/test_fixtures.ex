defmodule AwardsVoter.TestFixtures do
  
  alias AwardsVoter.Context.Admin
  alias AwardsVoter.Context.Voting
  alias AwardsVoter.Context.Voting.Ballots.Ballot
  alias AwardsVoter.Context.Voting.Votes.Vote
  alias AwardsVoter.Context.Admin.Shows.Show
  alias AwardsVoter.Context.Admin.Categories.Category
  alias AwardsVoter.Context.Admin.Contestants.Contestant
  
  def test_show(name \\ "Test Show") do
    %Show{
      name: name,
      categories: [
        %Category{
          name: "Test Category",
          description: "This is simply a test category.",
          winner: %Contestant{name: "Test Contestant 1"},
          contestants: [
            %Contestant{name: "Test Contestant 1"},
            %Contestant{name: "Test Contestant 2"},
            %Contestant{name: "Test Contestant 3"},
            %Contestant{name: "Test Contestant 4"}
          ]
        },
        %Category{name: "Test Category 2"},
        %Category{name: "Test Category 3"},
        %Category{name: "Test Category 4"}
      ]
    }
  end
  
  def test_category() do
    test_show().categories |> hd
  end
  
  def test_contestant() do
    test_show().categories |> hd |> Map.get(:contestants) |> hd
  end
  
  def saved_test_show(name \\ "Test Show") do
    test_show(name)
    |> Admin.show_to_map()
    |> Admin.create_show()
  end
  
  def test_ballot(username \\ "tester") do
    %Ballot{
      voter: username,
      votes: [
        %Vote{
          category: %Category{
            contestants: [
              %Contestant{
                billboard_stats: nil,
                description: nil,
                image_url: nil,
                name: "Test Contestant 1",
                spotify_url: nil,
                wiki_url: nil,
                youtube_url: nil
              },
              %Contestant{
                billboard_stats: nil,
                description: nil,
                image_url: nil,
                name: "Test Contestant 2",
                spotify_url: nil,
                wiki_url: nil,
                youtube_url: nil
              },
              %Contestant{
                billboard_stats: nil,
                description: nil,
                image_url: nil,
                name: "Test Contestant 3",
                spotify_url: nil,
                wiki_url: nil,
                youtube_url: nil
              },
              %Contestant{
                billboard_stats: nil,
                description: nil,
                image_url: nil,
                name: "Test Contestant 4",
                spotify_url: nil,
                wiki_url: nil,
                youtube_url: nil
              }
            ],
            description: "This is simply a test category.",
            name: "Test Category",
            winner: %Contestant{
              billboard_stats: nil,
              description: nil,
              image_url: nil,
              name: "Test Contestant 1",
              spotify_url: nil,
              wiki_url: nil,
              youtube_url: nil
            }
          },
          contestant: nil
        },
        %Vote{
          category: %Category{
            contestants: [],
            description: nil,
            name: "Test Category 2",
            winner: nil
          },
          contestant: nil
        },
        %Vote{
          category: %Category{
            contestants: [],
            description: nil,
            name: "Test Category 3",
            winner: nil
          },
          contestant: nil
        },
        %Vote{
          category: %Category{
            contestants: [],
            description: nil,
            name: "Test Category 4",
            winner: nil
          },
          contestant: nil
        }
      ]
    }
  end

  @doc """
    Used for testing ballot_controller. Returns a map for the selected votes, in the same format as would be passed into
    the controller by the ballot form. eg: %{"Test Category": "Selected Contestant"}
    Also returns the expected updated_ballot that should be persisted when these votes are saved.
  """
  def update_ballot_votes(ballot, num \\ 1) do
      taken_votes = Enum.take(ballot.votes, num)
      vote_map = Enum.map(taken_votes, fn vote -> {vote.category.name, vote.category.contestants |> hd |> Map.get(:name)} end) |> Map.new
      updated_ballot = %{ballot | votes: Enum.map(ballot.votes, fn vote ->
          case Enum.find(taken_votes, fn v -> v.category.name == vote.category.name end) do
            nil -> vote
            found_vote -> %{found_vote | contestant: found_vote.category.contestants |> hd}
          end
        end)}
      {vote_map, updated_ballot}
  end
  
  def saved_test_ballot(show_name \\ "Test Show", username \\ "tester") do
    Voting.create_new_ballot(username, show_name)
  end
end