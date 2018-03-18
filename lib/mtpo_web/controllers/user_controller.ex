defmodule MtpoWeb.UserController do
  use MtpoWeb, :controller

  alias Mtpo.Users
  alias Mtpo.Session

  action_fallback MtpoWeb.FallbackController

  def can_submit(conn, _params) do
    render(conn, "can_submit.json", %{user: Session.current_user(conn)})
  end

  def show(conn, id, status) do
    user = Users.get_user!(id)
    conn
    |> put_status(status)
    |> render("show.json", user: user)
  end
  def show(conn, %{"id" => id}) do
    show(conn, id, :ok)
  end

  def leaderboard(conn, _params) do
    render(conn, "leaderboard.json", %{})
  end
end
