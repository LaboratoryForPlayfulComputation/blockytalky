defmodule Blockytalky do
  use Application
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      ####
      # Web stuff
      # Start the endpoint when the application starts
      supervisor(Blockytalky.Endpoint, []),
      # Start the Ecto repository
      worker(Blockytalky.Repo, []),

      ####
      # BT IO stuff
      supervisor(Blockytalky.HardwareDaemon, []),
      supervisor(Blockytalky.CommsModule, []),
      #TODO: User Code / DSL Supervisor
      worker(Blockytalky.UserState,[])
    ]
    if Blockytalky.RuntimeUtils.music, do: children ++ [worker(Blockytalky.Music, [])]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Blockytalky.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Blockytalky.Endpoint.config_change(changed, removed)
    :ok
  end
end
