defmodule Mtpo.Application do
  use Application

  alias MtpoBot.Bot

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [supervisor(Mtpo.Repo, []), supervisor(MtpoWeb.Endpoint, [])]
    |> add_bot

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mtpo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MtpoWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  # Add the IRC bot only when not testing
  def add_bot(children) do
    import Supervisor.Spec
    case Mix.env do
      :test -> children
      _     -> children ++ [worker(Bot, [Application.get_env(:mtpo, :bot)])]
    end
  end
end
