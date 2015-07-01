defmodule Blockytalky.HardwareChannel do
  use Phoenix.Channel
  alias Blockytalky.MockHW, as: MockHW
  require Logger
  @moduledoc """
  Implemented based on example at:
  http://www.phoenixframework.org/v0.13.1/docs/channels

  See app.js for client side handling.
  """

  ####
  #External API
  def pub_mock_hw_message() do
    value = case MockHW.get_sensor_value(3) do
      {:ok, data} -> data
      _           -> ":("
    end
    Blockytalky.Endpoint.broadcast! "hardware:values", "mock",  %{body: value}
  end

  ####
  #Channel GenServer implementation
  #pattern match on param 1, a string like "topic:subtopic"
  def join("hardware:" <> _any, _auth_msg, socket) do
    Logger.debug "User joined socket: #{inspect socket}"
    {:ok, socket}
  end
  #def handle_in("hw_msg", payload, socket) #client server
  def handle_out(any, payload, socket) do
    push socket, any, payload
    {:noreply, socket}
  end

end
