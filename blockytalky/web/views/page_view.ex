defmodule Blockytalky.PageView do
  use Blockytalky.Web, :view
  def sensors do
    Blockytalky.HardwareDaemon.get_sensor_names
  end
  def sensor_width do
    "#{min(round(1 / length(sensors) * 100) - 5, 20)}%"
  end
  def btu_id do
    Application.get_env(:blockytalky, :id, "Unknown")
  end
end
