defmodule MtpoWeb.SessionHelper do
  require Logger

  use MtpoWeb, :controller
  alias Mtpo.Repo
  alias Mtpo.Users
  alias Mtpo.Sessions.Session

  def current_user!(conn) do
    case current_user(conn) do
      {:ok, user, _} -> user
      _ -> nil
    end
  end
  def current_user(conn) do
    try do
      "Bearer " <> token = get_req_header(conn, "authorization") |> List.first
      case Repo.get_by(Session, token: token) do
        nil ->
          {:error, :unauthorized}
        session ->
          # Only use the token if it's still valid
          if to_unix(session.expires_on) > :os.system_time(:second) do
            user = Users.get_user!(session.user_id)
            {:ok, user}
          end
      end
    rescue
      _ -> {:error, :unauthorized}
    end
  end

  def is_admin(conn) do
    user = current_user!(conn)
    not is_nil(user) and user.perm_level == :admin
  end

  def is_mod(conn) do
    user = current_user!(conn)
    not is_nil(user) and (user.perm_level == :admin or user.perm_level == :mod)
  end

  def logged_in?(conn), do: !!current_user!(conn)

  defp to_unix(datetime) do
    datetime
     |> DateTime.from_naive!("Etc/UTC")
     |> DateTime.to_unix
  end
end
