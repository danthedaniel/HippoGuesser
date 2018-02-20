defmodule Mtpo.Session do
  require Logger
  use MtpoWeb, :controller
  alias Mtpo.Users

  def current_user(conn) do
    if conn.assigns[:current_user] do
      Users.get_user!(conn.assigns[:current_user])
    else
      try do
        conn
        |> get_session(:user_id)
        |> Users.get_user!()
      rescue
        ArgumentError -> nil
      end
    end
  end

  def is_admin(conn) do
    user = current_user(conn)
    not is_nil(user) and user.perm_level == :admin
  end

  def is_mod(conn) do
    user = current_user(conn)
    not is_nil(user) and (user.perm_level == :admin or user.perm_level == :mod)
  end

  def logged_in?(conn), do: !!current_user(conn)
end
