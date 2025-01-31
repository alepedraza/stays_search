defmodule StaysSearch.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      StaysSearchWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:stays_search, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: StaysSearch.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: StaysSearch.Finch},
      # Start a worker by calling: StaysSearch.Worker.start_link(arg)
      # {StaysSearch.Worker, arg},
      # Start to serve requests, typically the last entry
      StaysSearchWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: StaysSearch.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    StaysSearchWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
