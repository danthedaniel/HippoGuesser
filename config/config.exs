# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :mtpo,
  ecto_repos: [Mtpo.Repo]

# Configures the endpoint
config :mtpo, MtpoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Jrz+YfCscKAkcw2xrCECIoKGTPr2AhTzR3qPzuwlT3oF5+ZHAehkxxsHCsC9JWBX",
  render_errors: [view: MtpoWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Mtpo.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
