defmodule MtpoWeb.RoundController do
  use MtpoWeb, :controller

  alias Mtpo.Rounds
  alias Mtpo.Rounds.Round

  action_fallback MtpoWeb.FallbackController

  def index(conn, _params) do
    round = Rounds.list_round()
    render(conn, "index.json", round: round)
  end

  def create(conn, %{"round" => round_params}) do
    with {:ok, %Round{} = round} <- Rounds.create_round(round_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", round_path(conn, :show, round))
      |> render("show.json", round: round)
    end
  end

  def show(conn, %{"id" => id}) do
    round = Rounds.get_round!(id)
    render(conn, "show.json", round: round)
  end

  def update(conn, %{"id" => id, "round" => round_params}) do
    round = Rounds.get_round!(id)

    with {:ok, %Round{} = round} <- Rounds.update_round(round, round_params) do
      render(conn, "show.json", round: round)
    end
  end

  def delete(conn, %{"id" => id}) do
    round = Rounds.get_round!(id)
    with {:ok, %Round{}} <- Rounds.delete_round(round) do
      send_resp(conn, :no_content, "")
    end
  end
end
