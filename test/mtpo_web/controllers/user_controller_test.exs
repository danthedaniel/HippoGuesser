defmodule MtpoWeb.UserControllerTest do
  use MtpoWeb.ConnCase

  alias Mtpo.Users

  @admin_attrs %{name: "teaearlgraycold", perm_level: :admin}
  @mod_attrs %{name: "summoningsalt", perm_level: :mod, whitelisted: true}
  @user_attrs %{name: "andrewg", perm_level: :user}

  def admin do
    {:ok, user} = Users.create_user(@admin_attrs)
    user
  end

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

  test "show is accessible without a current_user set", %{conn: conn} do
    pleb = user()
    conn
    |> get("/api/users/#{pleb.id}")
    |> json_response(200)
  end

  test "starts with empty leaderboard", %{conn: conn} do
    body = conn
    |> get("/api/leaderboard")
    |> json_response(200)
    assert Enum.count(body) == 0
  end

  test "says nil user can not submit", %{conn: conn} do
    body = conn
    |> get("/api/can_submit")
    |> json_response(200)
    assert !body["can_submit"]
  end

  test "says new user can submit", %{conn: conn} do
    pleb = user()
    body = conn
    |> Plug.Conn.assign(:current_user, pleb.id)
    |> get("/api/can_submit")
    |> json_response(200)
    assert body["can_submit"]
  end

  test "can return a list of whitelisted users", %{conn: conn} do
    body = conn
    |> get("/api/users/whitelist")
    |> json_response(200)
    assert is_list(body)
  end

  test "allows for users to be whitelisted", %{conn: conn} do
    god = admin()
    pleb = user()
    body = conn
    |> Plug.Conn.assign(:current_user, god.id)
    |> patch("/api/users/#{pleb.id}/whitelist")
    |> json_response(200)
    assert Map.get(body, "whitelisted")
  end

  test "allows for users to be un-whitelisted", %{conn: conn} do
    god = admin()
    pleb = mod()
    body = conn
    |> Plug.Conn.assign(:current_user, god.id)
    |> delete("/api/users/#{pleb.id}/whitelist")
    |> json_response(200)
    assert !Map.get(body, "whitelisted")
  end
end
