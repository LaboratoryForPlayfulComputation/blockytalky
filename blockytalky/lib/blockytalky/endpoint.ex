defmodule Blockytalky.Endpoint do
  use Phoenix.Endpoint, otp_app: :blockytalky


  ##websockets
  socket "/ws", Blockytalky.UserSocket
  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :blockytalky, gzip: false,
    only: ~w(css images js media favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_blockytalky_key",
    signing_salt: "UG/6ehSx"

  plug Blockytalky.Router
end
