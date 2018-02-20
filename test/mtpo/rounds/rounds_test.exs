defmodule Mtpo.RoundsTest do
  use Mtpo.DataCase

  alias Mtpo.Rounds

  describe "round" do
    # alias Mtpo.Rounds.Round

    test "current_round! sets the state to in_progress" do
      round = Rounds.current_round!
      assert round.state == :in_progress
    end

    test "create_round sets the state to in_progress" do
      {:ok, round} = Rounds.create_round
      assert round.state == :in_progress
    end

    test "current_round!" do
      assert Enum.count(Rounds.list_round) == 0
      _ = Rounds.current_round!
      assert Enum.count(Rounds.list_round) == 1
    end

    test "rounds that are in_progress can not be marked as closed" do
      round = Rounds.current_round!
      {:error, _} = Rounds.update_round(round, %{"state" => "closed"})
    end

    test "rounds that are in_progress can be marked as completed" do
      round = Rounds.current_round!
      {:ok, _} = Rounds.update_round(round, %{"state" => "completed"})
    end

    test "rounds can be moved to their current state" do
      round = Rounds.current_round!
      {:ok, _} = Rounds.update_round(round, %{"state" => "in_progress"})
    end

    test "rounds can not have a malformed correct_value" do
      round = Rounds.current_round!
      {:ok, _} = Rounds.update_round(round, %{"state" => "completed"})
      {:error, _} = Rounds.update_round(round, %{"state" => "closed", "correct_value" => "0:40."})
    end

    test "rounds accept a properly formed correct_value" do
      round = Rounds.current_round!
      {:ok, _} = Rounds.update_round(round, %{"state" => "completed"})
      {:error, _} = Rounds.update_round(round, %{"state" => "closed", "correct_value" => "0:40.99"})
    end
  end
end
