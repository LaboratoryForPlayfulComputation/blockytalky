defmodule Blockytalky.PageView do
  use Blockytalky.Web, :view
  alias Blockytalky.HardwareDaemon, as: HD
  #alias Blockytalky.UserState, as: US
  alias Blockytalky.BrickPi, as: BP
  alias Blockytalky.GrovePiState, as: GPS
  alias Blockytalky.BeagleBoneGreen, as: BBG
  alias Blockytalky.BeagleBoneGreenState, as: BBGS
  def sensors do
    HD.get_sensor_names
  end
  def size_of_sensor_bar do
    minimum = if :btgrovepi in Blockytalky.RuntimeUtils.supported_hardware, do: 5, else: 4  
    min(length(sensors),minimum)
    
  end
  def init_sensor_type(hw,port_id) do
    case hw do
      "mock" -> "None"
      "btbrickpi" -> BP.get_sensor_type(port_id) |> HD.get_sensor_type_label_for_id
      "btgrovepi" -> GPS.get_port_component(port_id) |> HD.get_sensor_type_label_for_id
      "beaglebonegreen" -> BBGS.get_port_component(port_id) |> HD.get_sensor_type_label_for_id
    end
  end
  def sensor_width do
    "#{min(round(1 / length(sensors) * 100) - 5, 20)}%"
  end
  def btu_id do
    Blockytalky.RuntimeUtils.btu_id
  end
end
