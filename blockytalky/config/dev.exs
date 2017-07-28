use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :blockytalky, Blockytalky.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  cache_static_lookup: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
           cd: Path.expand("../", __DIR__)]]

# Watch static and templates for browser reloading.
config :blockytalky, Blockytalky.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif)$},
      ~r{priv/static/vendor/.*(js|css|png|jpeg|jpg|gif)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]
config :logger, [
  level: :debug,
  backends: [Logger.Backends.Syslog, :console],
  syslog: [facility: :local2, appid: "BlockyTalky"]
]
# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Configure your database
#config :blockytalky, Blockytalky.Repo,
  #adapter: Ecto.Adapters.Postgres,
  #username: "postgres",
  #password: "postgres",
  #database: "blockytalky_dev",
  #size: 10 # The amount of database connections in the pool
  ####
  #custom configuration
config :blockytalky,
  supported_hardware: [:btgrovepi,:microbit],
  user_code_dir: "#{Path.dirname(__DIR__)}/priv/usercode"
