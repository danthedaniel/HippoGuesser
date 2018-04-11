defmodule MtpoWeb.UserController do
  use MtpoWeb, :controller

  alias Mtpo.Users
  alias Mtpo.Users.User
  alias MtpoWeb.SessionHelper

  action_fallback MtpoWeb.FallbackController

  def me(conn, _params) do
    with {:ok, %User{} = user} <- SessionHelper.current_user(conn) do
      show(conn, user, 200)
    end
  end

  def can_submit(conn, _params) do
    render(conn, "can_submit.json", %{user: SessionHelper.current_user!(conn)})
  end

  def whitelist(conn, %{"id" => id}) do
    status = if SessionHelper.is_admin(conn) do
      Users.update_user(Users.get_user!(id), whitelisted: true)
      :ok
    else
      :forbidden
    end
    show(conn, id, status)
  end

  def unwhitelist(conn, %{"id" => id}) do
    status = if SessionHelper.is_admin(conn) do
      Users.update_user(Users.get_user!(id), whitelisted: false)
      :ok
    else
      :forbidden
    end
    show(conn, id, status)
  end

  def show(_conn, nil, _status), do: {:error, :not_found}
  def show(conn, %User{} = user, status) do
    conn
    |> put_status(status)
    |> render("show.json", %{user: user})
  end
  def show(conn, id, status), do: show(conn, Users.get_user!(id), status)
  def show(conn, %{"id" => id}), do: show(conn, id, :ok)

  def leaderboard(conn, _params) do
    render(conn, "leaderboard.json", %{})
  end
end
