defmodule MtpoWeb.SessionController do
  use MtpoWeb, :controller
  alias Mtpo.{Users, Sessions}

  action_fallback MtpoWeb.FallbackController

  def auth(conn, _params) do
    state = SecureRandom.urlsafe_base64(16)
    conn = put_session(conn, :state, state)
    redirect(conn, external: Twitch.authorize_url!(state))
  end

  def callback(conn, %{"state" => state, "code" => code}) do
    if get_session(conn, :state) == state do
      token = Twitch.get_token!(code)
      username = Twitch.get_username(token["access_token"]) |> String.downcase
      {:ok, user} = Users.create_or_get_user(%{name: username})
      {:ok, session} = Sessions.create_session_from_token(token, user)

      cookies = %{"twitch_token" => session.token}
      conn = conn
      |> add_cookies(cookies, max_age: token["expires_in"], http_only: false)
      |> put_resp_header("Access-Control-Allow-Credentials", "true")
      redirect(conn, to: "/")
    else
      redirect(conn, to: "/")
    end
  end

  def logout(conn, _params) do
    cookies = ["twitch_token"]
    redirect(remove_cookies(conn, cookies), to: "/")
  end

  defp add_cookies(conn, cookies, opts) when is_map(cookies) do
    Enum.reduce(cookies, conn, fn({k, v}, acc) ->
      put_resp_cookie(acc, k, v, opts)
    end)
  end

  defp remove_cookies(conn, cookies) when is_list(cookies) do
    Enum.reduce(cookies, conn, &delete_resp_cookie(&2, &1))
  end
end
