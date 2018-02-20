defmodule MtpoWeb.UserController do
  use MtpoWeb, :controller

  alias Mtpo.Users
  alias Mtpo.Session

  action_fallback MtpoWeb.FallbackController

  def show(conn, id, status) do
    user = Users.get_user!(id)
    conn
    |> put_status(status)
    |> render("show.json", user: user)
  end
  def show(conn, %{"id" => id}) do
    show(conn, id, :ok)
  end

  def make_mod(conn, %{"id" => id}) do
    if Session.is_admin(conn) do
      user = Users.get_user!(id)
      Users.update_user(user, %{perm_level: :mod})
      show(conn, id, :ok)
    else
      show(conn, id, :forbidden)
    end
  end

  def make_admin(conn, %{"id" => id}) do
    if Session.is_admin(conn) do
      user = Users.get_user!(id)
      Users.update_user(user, %{perm_level: :admin})
      show(conn, id, :ok)
    else
      show(conn, id, :forbidden)
    end
  end
end
