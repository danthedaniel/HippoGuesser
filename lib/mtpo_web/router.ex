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
    resources "/users", UserController, except: [:new, :edit]
    resources "/round", RoundController, except: [:new, :edit]
  end

  scope "/", MtpoWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/auth/twitch", SessionController, :auth
    get "/auth/twitch/callback", SessionController, :callback
    get "/auth/logout", SessionController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", MtpoWeb do
  #   pipe_through :api
  # end
end
