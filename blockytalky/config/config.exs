# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :blockytalky, Blockytalky.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "a7NmeMdzJJY1pE0J0ITT+N+qaKI/Qf8D309sH0bYPPHtTen4sJDCVlUh68ePDMNg",
  debug_errors: false,
  pubsub: [name: Blockytalky.PubSub,
           adapter: Phoenix.PubSub.PG2],
  check_origin: false
# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]
config :blockytalky,
  dax: "ws://btrouter.getdown.org:8005/dax",
  music: true, #set to true if sonic pi is running / this is a synth unit
  music_port: 9090,
  music_eval_port: 5050,
  update_rate: 30,
  update_rate_hibernate: 100

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
