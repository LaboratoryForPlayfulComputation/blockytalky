defmodule Blockytalky.HardwareChannel do
  use Phoenix.Channel
  alias Blockytalky.MockHW, as: MockHW
  alias Blockytalky.BrickPi, as: BP
  alias Blockytalky.GrovePi, as: GP
  alias Blockytalky.GrovePiState, as: GPS
  alias Blockytalky.BeagleBoneGreen, as: BBG
  alias Blockytalky.BeagleBoneGreenState, as: BBGS
  #alias Blockytalky.UserState, as: US
  alias Blockytalky.HardwareDaemon, as: HD
  require Logger
  @moduledoc """
  Implemented based on example at:
  http://www.phoenixframework.org/v0.13.1/docs/channels

  See app.js for client side handling.
  """

  ####
  #External API


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
    #switch hardware state and tell appropriate python module
    case hw do
      "btbrickpi" ->
        BP.set_sensor_type(port_id, sensor_type)
      "mock" ->
        MockHW.set_sensor_type(port_id, sensor_type)
      "btgrovepi" ->
        GP.set_component_type(String.to_atom(port_id), String.to_atom(sensor_type))
      "beaglebonegreen" ->
        BBG.set_component_type(String.to_atom(port_id), String.to_atom(sensor_type))
        _ -> :ok
    end
    #broadcast that the change has occured:
    sensor_label = HD.get_sensor_type_label_for_id(sensor_type)
    Logger.debug "update sensor type: #{port_id} with #{sensor_label}"
    push socket, "sensor_changed", %{"port_id" => port_id, "sensor_label" => sensor_label} #client's don't need the type, this is just to change the label.
    {:noreply, socket}
  end

  def handle_out(any, payload, socket) do
    push socket, any, payload
    {:noreply, socket}
  end

end
