defmodule MtpoWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use MtpoWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(MtpoWeb.ChangesetView, "error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    send_resp(conn, 404, "")
    # |> render("error.json", "not_found")
  end

  def call(conn, {:error, :unauthorized}) do
    send_resp(conn, 403, "")
    # |> render("error.json", "unauthorized")
  end
end
