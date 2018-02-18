defmodule MtpoWeb.RoundView do
  use MtpoWeb, :view
  alias MtpoWeb.RoundView

  def render("index.json", %{round: round}) do
    %{data: render_many(round, RoundView, "round.json")}
  end

  def render("show.json", %{round: round}) do
    %{data: render_one(round, RoundView, "round.json")}
  end

  def render("round.json", %{round: round}) do
    %{id: round.id,
      start_time: round.start_time,
      end_time: round.end_time,
      state: round.state,
      started_by: round.started_by}
  end
end
