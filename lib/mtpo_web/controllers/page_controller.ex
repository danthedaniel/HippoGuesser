defmodule MtpoWeb.PageController do
  use MtpoWeb, :controller

  alias Mtpo.Session

  def index(conn, _params) do
    if Session.logged_in?(conn) do
      user = Session.current_user(conn)
      # Re-set the user's role cookie in case it has changed
      conn
      |> put_resp_cookie("role", Atom.to_string(user.perm_level), http_only: false)
      |> put_resp_header("Access-Control-Allow-Credentials", "true")
      |> render("index.html")
    else
      render(conn, "index.html")
    end
  end
end
