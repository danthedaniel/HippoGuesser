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

    get "/users/:id", UserController, :show
    patch "/users/:id/mod", UserController, :make_mod
    patch "/users/:id/admin", UserController, :make_admin

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
    get "/auth/logout", SessionController, :delete
  end
end
