defmodule Blockytalky.HardwareChannel do
  use Phoenix.Channel
  alias Blockytalky.HardwareDaemon, as: HardwareDaemon
  require Logger
  @moduledoc """
  Implemented based on example at:
  http://www.phoenixframework.org/v0.13.1/docs/channels

  See app.js for client side handling.
  """

  ####
  #External API
  def pub_mock_hw_message() do
    value = case HardwareDaemon.get_sensor_value(:mock,3) do
      {:ok, data} -> data
      _           -> ":("
    end
    Blockytalky.Endpoint.broadcast! "hardware:mock", "hw_msg",  %{body: value}
  end

  ####
  #Channel GenServer implementation
  #pattern match on param 1, a string like "topic:subtopic"
  def join("hardware:" <> any, auth_msg, socket) do
    Logger.debug "User joined socket: #{inspect socket}"
    {:ok, socket}
  end

  def handle_out("hw_msg", payload, socket) do
    push socket, "hw_msg", payload
    {:noreply, socket}
  end

end
