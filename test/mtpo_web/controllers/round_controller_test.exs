defmodule MtpoWeb.RoundControllerTest do
  use MtpoWeb.ConnCase
  alias Mtpo.{Rounds, Users, Guesses}

  @mod_attrs %{name: "summoningsalt", perm_level: :mod}
  @user_attrs %{name: "andrewg", perm_level: :user}

  def mod do
    {:ok, user} = Users.create_user(@mod_attrs)
    user
  end

  def user do
    {:ok, user} = Users.create_user(@user_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "mods can start a new round", %{conn: conn} do
    assert Enum.count(Rounds.list_round) == 0
    god = mod()
    conn
    |> Plug.Conn.assign(:current_user, god.id)
    |> patch("/api/rounds/current/change/in_progress")
    |> json_response(200)
    assert Enum.count(Rounds.list_round) == 1
  end

  test "mods can mark a round as completed", %{conn: conn} do
    Rounds.current_round!
    god = mod()
    conn
    |> Plug.Conn.assign(:current_user, god.id)
    |> patch("/api/rounds/current/change/completed")
    |> json_response(200)
    assert Rounds.current_round!.state == :completed
  end

  test "mods can mark a round as closed", %{conn: conn} do
    Rounds.update_round(Rounds.current_round!, %{state: :completed})
    god = mod()
    conn
    |> Plug.Conn.assign(:current_user, god.id)
    |> patch("/api/rounds/current/change/closed?correct=0:40.99")
    |> json_response(200)
    assert Rounds.current_round!.state == :closed
  end

  test "new rounds can be started when current one is closed", %{conn: conn} do
    Rounds.update_round(Rounds.current_round!, %{state: :completed})
    Rounds.update_round(Rounds.current_round!, %{state: :closed})
    god = mod()
    conn
    |> Plug.Conn.assign(:current_user, god.id)
    |> patch("/api/rounds/current/change/in_progress")
    |> json_response(200)
    assert Enum.count(Rounds.list_round) == 2
  end

  test "users can not change the round state", %{conn: conn} do
    Rounds.current_round!
    pleb = user()
    conn
    |> Plug.Conn.assign(:current_user, pleb.id)
    |> patch("/api/rounds/current/change/completed")
    |> json_response(403)
    assert Rounds.current_round!.state == :in_progress
  end

  test "users can guess during in_progress rounds", %{conn: conn} do
    assert Enum.count(Guesses.list_guesses) == 0
    pleb = user()
    conn
    |> Plug.Conn.assign(:current_user, pleb.id)
    |> post("/api/rounds/current/guess?value=0:40.99")
    |> json_response(200)
    assert Enum.count(Guesses.list_guesses) == 1
  end

  test "users can not guess during completed rounds", %{conn: conn} do
    Rounds.update_round(Rounds.current_round!, %{state: :completed})
    assert Enum.count(Guesses.list_guesses) == 0
    pleb = user()
    conn
    |> Plug.Conn.assign(:current_user, pleb.id)
    |> post("/api/rounds/current/guess?value=0:40.99")
    |> json_response(400)
    assert Enum.count(Guesses.list_guesses) == 0
  end

  test "current_user must be set to guess", %{conn: conn} do
    post(conn, "/api/rounds/current/guess?value=0:40.99")
    assert Enum.count(Guesses.list_guesses) == 0
  end
end
