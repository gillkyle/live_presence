defmodule LivePresence.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LivePresenceWeb.Telemetry,
      LivePresence.Repo,
      {DNSCluster, query: Application.get_env(:live_presence, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: LivePresence.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: LivePresence.Finch},
      # Start a worker by calling: LivePresence.Worker.start_link(arg)
      # {LivePresence.Worker, arg},
      # Start to serve requests, typically the last entry
      LivePresenceWeb.Endpoint,
      LivePresenceWeb.Presence
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LivePresence.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LivePresenceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
