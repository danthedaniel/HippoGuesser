defmodule Twitch do
  use OAuth2.Strategy

  # Public API

  def client do
    OAuth2.Client.new([
      strategy: __MODULE__,
      client_id: System.get_env("TWITCH_CLIENT_ID"),
      client_secret: System.get_env("TWITCH_CLIENT_SECRET"),
      site: "https://api.twitch.tv",
      authorize_url: "https://api.twitch.tv/kraken/oauth2/authorize",
      redirect_uri: "http://localhost:4000/auth/twitch/callback",
      token_url: "https://api.twitch.tv/api/oauth2/token"
    ])
  end

  def authorize_url!(state) do
    client()
    |> put_param(:state, state)
    |> put_param(:scope, "openid user_read")
    |> OAuth2.Client.authorize_url!
  end

  # Twitch.get_username("ehdyi85k85yn64nudyxbdg98habjle")
  def get_username(token) do
    c = client()
    |> put_header("Client-ID", client().client_id)
    |> put_header("Authorization", "OAuth " <> token)

    case OAuth2.Client.get(c, "/kraken/user") do
      {:ok, resp} -> resp.body["display_name"]
      {:error, _} -> nil
    end
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  # Twitch.get_token!("uiuhf9sd9u2w38n9g7lvmmmw7upiv7")
  def get_token!(code) do
    c = client()
    |> put_param(:client_secret, client().client_secret)
    |> put_param(:client_id, client().client_id)
    |> put_param(:redirect_uri, client().redirect_uri)
    |> put_param(:code, code)
    |> put_param(:grant_type, "authorization_code")
    |> put_header("accept", "application/json")

    case OAuth2.Client.post(c, "/api/oauth2/token", "", [], [params: c.params]) do
      {:ok, resp} -> resp.body
      {:error, _} -> nil
    end
  end
end
