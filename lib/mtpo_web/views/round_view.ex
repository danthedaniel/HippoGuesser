defmodule MtpoWeb.RoundView do
  use MtpoWeb, :view
  alias MtpoWeb.RoundView

  def render("index.json", %{round: round}) do
    render_many(round, RoundView, "round.json")
  end

  def render("show.json", %{round: round}) do
    render_one(round, RoundView, "round.json")
  end

  def render("round.json", %{round: round}) do
    %{id: round.id,
      state: round.state}
  end
end
