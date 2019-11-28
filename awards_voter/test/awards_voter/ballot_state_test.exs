defmodule AwardsVoter.BallotStateTest do
  use ExUnit.Case
  
  alias AwardsVoter.BallotState
  
  @all_states [:initialized, :show_set, :ballot_set, :voting, :submitted, :show_ended, :get_score, :reset_state]
  
  describe "BallotState.new/0" do
    test "Brand new ballot state is returned with a status of :initialized" do
      assert {:ok, %BallotState{status: :initialized}} = BallotState.new()
    end
  end
  describe "BallotState.check/2" do
    test "From :initialized, must set a show first" do
      allowed_transitions = [:set_show, :reset_state]
      start_state = :initialized
      assert test_state_transition(start_state, allowed_transitions)
    end
    test "From :show_set, allowed to reset the show, or must set a ballot" do
      allowed_transitions = [:set_show, :set_ballot, :reset_state]
      start_state = :show_set
      assert test_state_transition(start_state, allowed_transitions)
    end
    test "From :ballot_set, allowed to reset the ballot, or must start voting" do
      allowed_transitions = [:set_ballot, :vote, :reset_state]
      start_state = :ballot_set
      assert test_state_transition(start_state, allowed_transitions)
    end
    test "From :voting, can continue to vote, or must submit the ballot or show can end" do
      allowed_transitions = [:vote, :submit, :end_show, :reset_state]
      start_state = :voting
      assert test_state_transition(start_state, allowed_transitions)
    end
    test "From :submitted, can return to voting, or resubmit the ballot, or show can end" do
      allowed_transitions = [:vote, :submit, :get_score, :end_show, :reset_state]
      start_state = :submitted
      assert test_state_transition(start_state, allowed_transitions)
    end
    test "From :show_ended, can get the score of the ballot" do
      allowed_transitions = [:get_score]
      start_state = :show_ended
      assert test_state_transition(start_state, allowed_transitions)
    end
  end
  
  defp test_state_transition(start_state, transitions) do
    allowed = all_transitions_allowed(start_state, transitions)
    not_allowed = all_transitions_refused(start_state, @all_states -- transitions)
    allowed and not_allowed
  end
  
  defp all_transitions_allowed(start_state, allowed_transitions) do
    Enum.all?(allowed_transitions, fn trans ->
      case BallotState.check(%BallotState{status: start_state}, trans) do
        {:ok, %BallotState{}} -> true
        _ -> false
      end
    end)
  end
  
  defp all_transitions_refused(start_state, refused_transitions) do
    Enum.all?(refused_transitions, fn trans ->
      case BallotState.check(%BallotState{status: start_state}, trans) do
        {:ok, %BallotState{}} -> false
        _ -> true
      end
    end)
  end
end