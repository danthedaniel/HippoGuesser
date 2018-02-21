defmodule MtpoWeb.UserControllerTest do
  use MtpoWeb.ConnCase

  alias Mtpo.Users

  @admin_attrs %{name: "teaearlgraycold", perm_level: :admin}
  @mod_attrs %{name: "summoningsalt", perm_level: :mod}
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

  test "admins can elevate other users to mod", %{conn: conn} do
    pleb = user()
    god = admin()
    conn
    |> Plug.Conn.assign(:current_user, god.id)
    |> patch("/api/users/#{pleb.id}/mod")
    |> json_response(200)
    assert Users.get_user!(pleb.id).perm_level == :mod
  end

  test "admins can elevate other users to admin", %{conn: conn} do
    pleb = user()
    god = admin()
    conn
    |> Plug.Conn.assign(:current_user, god.id)
    |> patch("/api/users/#{pleb.id}/admin")
    |> json_response(200)
    assert Users.get_user!(pleb.id).perm_level == :admin
  end

  test "mods can not elevate other users", %{conn: conn} do
    pleb = user()
    god = mod()
    conn
    |> Plug.Conn.assign(:current_user, god.id)
    |> patch("/api/users/#{pleb.id}/mod")
    |> json_response(403)
    assert Users.get_user!(pleb.id).perm_level == :user
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
end
