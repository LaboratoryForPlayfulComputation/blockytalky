use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
# Currently the auto-generated default (not-sensitive). Remove from git and make BTU specific if need be.
config :blockytalky, Blockytalky.Endpoint,
  secret_key_base: "Kr/XoPRzKE/LIrVn2ugw8mtnkftj3C83hhELSbR49ZXM1HkljuB7rUTlOOX8e9zT"

# Configure your database
config :blockytalky, Blockytalky.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "blockytalky_prod",
  size: 20 # The amount of database connections in the pool
