defmodule MtpoWeb.Router do
  use MtpoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  scope "/api", MtpoWeb do
    pipe_through :api

    get "/leaderboard", UserController, :leaderboard
    get "/can_submit", UserController, :can_submit
    get "/users/me", UserController, :me
    get "/users/whitelist", UserController, :show_whitelist
    get "/users/:id", UserController, :show
    patch "/users/:id/whitelist", UserController, :whitelist
    delete "/users/:id/whitelist", UserController, :unwhitelist

    get "/rounds/:id", RoundController, :show
    get "/rounds/current", RoundController, :current
    post "/rounds/current/guess", RoundController, :guess
    patch "/rounds/current/change/:state", RoundController, :change_state
  end

  scope "/", MtpoWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/auth/twitch", SessionController, :auth
    get "/auth/twitch/callback", SessionController, :callback
    get "/auth/logout", SessionController, :logout

    # For react router
    get "/*path", PageController, :index
  end
end
