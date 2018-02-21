defmodule MtpoWeb.UserView do
  use MtpoWeb, :view
  alias MtpoWeb.UserView
  alias Mtpo.Users
  alias Mtpo.Users.User

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      name: user.name,
      wins: 0}
  end

  def render("leaderboard.json", _params), do: Users.leaderboard

  def render("can_submit.json", %{user: nil}), do: %{can_submit: false}
  def render("can_submit.json", %{user: %User{} = user}) do
    %{can_submit: !Users.has_guessed(user)}
  end
end
