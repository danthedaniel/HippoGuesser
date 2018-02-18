defmodule Mtpo.RoundsTest do
  use Mtpo.DataCase

  alias Mtpo.Rounds

  describe "round" do
    alias Mtpo.Rounds.Round

    @valid_attrs %{end_time: ~N[2010-04-17 14:00:00.000000], start_time: ~N[2010-04-17 14:00:00.000000], started_by: 42, state: 42}
    @update_attrs %{end_time: ~N[2011-05-18 15:01:01.000000], start_time: ~N[2011-05-18 15:01:01.000000], started_by: 43, state: 43}
    @invalid_attrs %{end_time: nil, start_time: nil, started_by: nil, state: nil}

    def round_fixture(attrs \\ %{}) do
      {:ok, round} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Rounds.create_round()

      round
    end

    test "list_round/0 returns all round" do
      round = round_fixture()
      assert Rounds.list_round() == [round]
    end

    test "get_round!/1 returns the round with given id" do
      round = round_fixture()
      assert Rounds.get_round!(round.id) == round
    end

    test "create_round/1 with valid data creates a round" do
      assert {:ok, %Round{} = round} = Rounds.create_round(@valid_attrs)
      assert round.end_time == ~N[2010-04-17 14:00:00.000000]
      assert round.start_time == ~N[2010-04-17 14:00:00.000000]
      assert round.started_by == 42
      assert round.state == 42
    end

    test "create_round/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rounds.create_round(@invalid_attrs)
    end

    test "update_round/2 with valid data updates the round" do
      round = round_fixture()
      assert {:ok, round} = Rounds.update_round(round, @update_attrs)
      assert %Round{} = round
      assert round.end_time == ~N[2011-05-18 15:01:01.000000]
      assert round.start_time == ~N[2011-05-18 15:01:01.000000]
      assert round.started_by == 43
      assert round.state == 43
    end

    test "update_round/2 with invalid data returns error changeset" do
      round = round_fixture()
      assert {:error, %Ecto.Changeset{}} = Rounds.update_round(round, @invalid_attrs)
      assert round == Rounds.get_round!(round.id)
    end

    test "delete_round/1 deletes the round" do
      round = round_fixture()
      assert {:ok, %Round{}} = Rounds.delete_round(round)
      assert_raise Ecto.NoResultsError, fn -> Rounds.get_round!(round.id) end
    end

    test "change_round/1 returns a round changeset" do
      round = round_fixture()
      assert %Ecto.Changeset{} = Rounds.change_round(round)
    end
  end
end
