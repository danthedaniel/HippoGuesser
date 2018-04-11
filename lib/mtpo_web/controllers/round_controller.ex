defmodule MtpoWeb.RoundController do
  use MtpoWeb, :controller

  alias Mtpo.Rounds
  alias Mtpo.Rounds.Round
  alias Mtpo.Users
  alias Mtpo.Users.User
  alias MtpoWeb.SessionHelper
  alias Mtpo.Guesses

  action_fallback MtpoWeb.FallbackController

  def current(conn, _params) do
    round = Rounds.current_round!
    conn
    |> put_status(:ok)
    |> put_resp_header("location", round_path(conn, :show, round))
    |> render("show.json", round: round)
  end

  def change_state(conn, %{"state" => "closed", "correct" => correct}) do
    round = Rounds.current_round!
    current_user = SessionHelper.current_user!(conn)
    if Users.can_state_change(current_user) do
      changeset = %{"state" => "closed", "correct_value" => correct}
      {:ok, round} = Rounds.update_round(round, changeset)
      show(conn, :ok, round)
    else
      show(conn, :forbidden, round)
    end
  end
  def change_state(conn, %{"state" => "in_progress"}) do
    current_user = SessionHelper.current_user!(conn)
    if Users.can_state_change(current_user) do
      case Rounds.current_round!.state do
        :closed ->
          {:ok, round} = Rounds.create_round
          show(conn, :ok, round)
        :in_progress -> show(conn, :ok, Rounds.current_round!)
        :completed -> show(conn, 400, Rounds.current_round!)
      end
    else
      show(conn, :forbidden, Rounds.current_round!)
    end
  end
  def change_state(conn, %{"state" => "completed"}) do
    round = Rounds.current_round!
    current_user = SessionHelper.current_user!(conn)
    if Users.can_state_change(current_user) do
      case Rounds.update_round(round, %{"state" => "completed"}) do
        {:ok, _} -> show(conn, :ok, round)
        {:error, _} -> show(conn, 400, round)
      end
    else
      show(conn, :forbidden, round)
    end
  end

  def guess(conn, %{"value" => value}) do
    with {:ok, %User{} = user} <- SessionHelper.current_user(conn) do
      round = Rounds.current_round!
      changeset = %{
        "round_id" => round.id,
        "user_id" => user.id,
        "value" => value
      }
      case Guesses.create_guess(changeset) do
        {:ok, _} -> show(conn, :ok, round)
        {:error, _} -> show(conn, 400, round)
      end
    end
  end

  def show(conn, %{"id" => id}), do: show(conn, :ok, Rounds.get_round!(id))
  def show(conn, status, %Round{} = round) do
    conn
    |> put_status(status)
    |> put_resp_header("location", round_path(conn, :show, round))
    |> render("show.json", round: round)
  end
end
