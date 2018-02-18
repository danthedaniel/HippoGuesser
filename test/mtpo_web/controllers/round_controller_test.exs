defmodule MtpoWeb.RoundControllerTest do
  use MtpoWeb.ConnCase

  alias Mtpo.Rounds
  alias Mtpo.Rounds.Round

  @create_attrs %{end_time: ~N[2010-04-17 14:00:00.000000], start_time: ~N[2010-04-17 14:00:00.000000], started_by: 42, state: 42}
  @update_attrs %{end_time: ~N[2011-05-18 15:01:01.000000], start_time: ~N[2011-05-18 15:01:01.000000], started_by: 43, state: 43}
  @invalid_attrs %{end_time: nil, start_time: nil, started_by: nil, state: nil}

  def fixture(:round) do
    {:ok, round} = Rounds.create_round(@create_attrs)
    round
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all round", %{conn: conn} do
      conn = get conn, round_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create round" do
    test "renders round when data is valid", %{conn: conn} do
      conn = post conn, round_path(conn, :create), round: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, round_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "end_time" => ~N[2010-04-17 14:00:00.000000],
        "start_time" => ~N[2010-04-17 14:00:00.000000],
        "started_by" => 42,
        "state" => 42}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, round_path(conn, :create), round: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update round" do
    setup [:create_round]

    test "renders round when data is valid", %{conn: conn, round: %Round{id: id} = round} do
      conn = put conn, round_path(conn, :update, round), round: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, round_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "end_time" => ~N[2011-05-18 15:01:01.000000],
        "start_time" => ~N[2011-05-18 15:01:01.000000],
        "started_by" => 43,
        "state" => 43}
    end

    test "renders errors when data is invalid", %{conn: conn, round: round} do
      conn = put conn, round_path(conn, :update, round), round: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete round" do
    setup [:create_round]

    test "deletes chosen round", %{conn: conn, round: round} do
      conn = delete conn, round_path(conn, :delete, round)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, round_path(conn, :show, round)
      end
    end
  end

  defp create_round(_) do
    round = fixture(:round)
    {:ok, round: round}
  end
end
