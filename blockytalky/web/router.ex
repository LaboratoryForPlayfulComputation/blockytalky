defmodule Blockytalky.Router do
  use Blockytalky.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Blockytalky do
    pipe_through :browser # Use the default browser stack
    get "/", PageController, :index
  end
  #http://www.phoenixframework.org/v0.13.1/docs/channels
  socket "/ws", Blockytalky do
    channel "hardware:*", HardwareChannel
    channel "comms:*", CommsChannel
    channel "uc:*", UserCodeChannel
  end
  # Other scopes may use custom stacks.
  # scope "/api", Blockytalky do
  #   pipe_through :api
  # end
end
