defmodule AwardsVoter.Web.BallotViewTest do
  use AwardsVoter.Web.ConnCase, async: true
  
  import Phoenix.View
  import Phoenix.HTML, only: [safe_to_string: 1]

  alias AwardsVoter.Web.BallotView
  alias AwardsVoter.Context.Admin.Contestants.Contestant
  alias AwardsVoter.Context.Admin.Categories.Category
  alias AwardsVoter.Context.Voting.Votes.Vote
  alias AwardsVoter.Context.Voting
  alias AwardsVoter.Context.Voting.Ballots.Ballot
  
  describe "render_vote_options/2" do
    setup do
      vote = %Vote{
        contestant: %Contestant{name: "Test Contestant 1"},
        category: %Category{
          name: "Test Category",
          contestants: [
            %Contestant{name: "Test Contestant 1"},
            %Contestant{name: "Test Contestant 2"},
            %Contestant{name: "Test Contestant 3"},
            %Contestant{name: "Test Contestant 4"}
          ]
        }
      }
      {:ok, vote: vote}
    end
    
    test "with a voted contestant set", %{vote: vote} do
      res = BallotView.render_vote_options(:form, vote) |> safe_to_string()

      assert res =~ "<input id=\"form_Test Category_Test_Contestant_1\" name=\"form[Test Category]\" type=\"radio\" value=\"Test Contestant 1\" checked>"
      for num <- 2..4 do
        assert res =~ "<input id=\"form_Test Category_Test_Contestant_#{num}\" name=\"form[Test Category]\" type=\"radio\" value=\"Test Contestant #{num}\">"
      end
    end
    
    test "with no contestant vote set", %{vote: vote} do
      vote = %{vote | contestant: nil}
      res = BallotView.render_vote_options(:form, vote) |> safe_to_string()

      refute res =~ "<input id=\"form_Test Category_Test_Contestant_1\" name=\"form[Test Category]\" type=\"radio\" value=\"Test Contestant 1\" checked>"
      for num <- 1..4 do
        assert res =~ "<input id=\"form_Test Category_Test_Contestant_#{num}\" name=\"form[Test Category]\" type=\"radio\" value=\"Test Contestant #{num}\">"
      end
    end
  end
  
  describe "renders templates correctly: " do
    setup do
      ballot = %Ballot{
        voter: "Test Voter",
        votes: [
          %Vote{
            category: %Category{
              name: "Test Category 1",
              contestants: [
                %Contestant{name: "Test Contestant 1"},
                %Contestant{name: "Test Contestant 2"}
              ]
            }
          },
          %Vote{
            category: %Category{
              name: "Test Category 2",
              contestants: [
                %Contestant{name: "Test Contestant 3"},
                %Contestant{name: "Test Contestant 4"}
              ]
            }
          }
        ]
      }
      {:ok, ballot: ballot}
    end
    
    test "new.html", %{conn: conn} do
      changeset = Voting.change_ballot(%Ballot{})
      show_name = "Test Show"
      content = render_to_string(AwardsVoter.Web.BallotView, "new.html", conn: conn, show_name: show_name, changeset: changeset)

      assert content =~ "New Ballot for Test Show"
      assert content =~ "<button type=\"submit\">Save</button>"
      assert content =~ "<label for=\"ballot_username\">Username</label><input id=\"ballot_username\" name=\"ballot[username]\" type=\"text\">"
    end
    
    test "continue.html", %{conn: conn} do
      changeset = Voting.change_ballot(%Ballot{})
      show_name = "Test Show"
      content = render_to_string(AwardsVoter.Web.BallotView, "continue.html", conn: conn, show_name: show_name, changeset: changeset)
      
      assert content =~ "Continue existing ballot for Test Show"
      assert content =~ "<button type=\"submit\">Continue</button>"
      assert content =~ "<label for=\"ballot_username\">Username</label><input id=\"ballot_username\" name=\"ballot[username]\" type=\"text\">"
    end

    test "edit.html", %{conn: conn, ballot: ballot} do
      changeset = Voting.change_ballot(ballot)
      show_name = "Test Show"
      content = render_to_string(AwardsVoter.Web.BallotView, "edit.html", conn: conn,
        show_name: show_name, changeset: changeset, options: [method: "put"])

      assert content =~ ballot.voter
      assert content =~ show_name
      assert content =~ "<input name=\"_method\" type=\"hidden\" value=\"put\">"
      assert content =~ "/ballot/#{URI.encode(show_name)}/#{URI.encode(ballot.voter)}"
      for num <- 1..2 do
        assert content =~ "<h2>Test Category #{num}</h2>"
        assert content =~ "<label>\n    <span>Test Contestant #{num}</span>"
      end
    end

    test "show.html", %{conn: conn, ballot: ballot} do
      show_name = "Test Show"
      content = render_to_string(AwardsVoter.Web.BallotView, "show.html", conn: conn, show_name: show_name, ballot: ballot)

      assert content =~ ballot.voter
    end
  end
end