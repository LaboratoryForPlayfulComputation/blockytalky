defmodule Blockytalky.PageView do
  use Blockytalky.Web, :view
  alias Blockytalky.HardwareDaemon, as: HD
  #alias Blockytalky.UserState, as: US
  alias Blockytalky.BrickPi, as: BP
  def sensors do
    HD.get_sensor_names
  end
  def init_sensor_type(hw,port_id) do
    case hw do
      "mock" -> "None"
      "btbrickpi" -> BP.get_sensor_type(port_id) |> HD.get_sensor_type_label_for_id
    end
  end
  def sensor_width do
    "#{min(round(1 / length(sensors) * 100) - 5, 20)}%"
  end
  def btu_id do
    Blockytalky.RuntimeUtils.btu_id
  end
end
