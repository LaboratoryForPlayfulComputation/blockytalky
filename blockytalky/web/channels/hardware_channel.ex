defmodule Blockytalky.HardwareChannel do
  use Phoenix.Channel
  alias Blockytalky.MockHW, as: MockHW
  alias Blockytalky.BrickPi, as: BP
  alias Blockytalky.UserState, as: US
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
  #Channel implementation
  #pattern match on param 1, a string like "topic:subtopic"
  def join("hardware:" <> _any, _auth_msg, socket) do
    #Logger.debug "User joined socket: #{inspect socket}"
    {:ok, socket}
  end
  @doc """
  msg has the form:
  %{hw => hw_name, "port_id" => port_id, sensor_type => sensor_type(friendly name)}
  e.g.
  %{"hw" => "btbrickpi", "port_id" => "Mock_1", "sensor_name" => "Ultrasonic"}
  """
  def handle_in("change_sensor_type", %{"hw" => hw, "port_id" => port_id, "sensor_type" => sensor_type}, socket) do
    #switch hardware state
    case hw do
      "btbrickpi" ->
        BrickPi.set_sensor_type(port_id, sensor_type)
      _ ->
        Mock.set_sensor_type(port_id, sensor_type)
    end
    #tell appropriate python module
    {:noreply, socket}
  end
  def handle_out(any, payload, socket) do
    push socket, any, payload
    {:noreply, socket}
  end

end
