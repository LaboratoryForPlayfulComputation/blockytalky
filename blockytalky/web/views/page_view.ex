defmodule Blockytalky.PageView do
  use Blockytalky.Web, :view
  def sensors do
    Blockytalky.UserState.get_sensor_names
  end
  def sensor_width do
    "#{round(1 / length(sensors) * 100)}%"
  end
  def btu_id do
    Application.get_env(:blockytalky, :id, "Unknown")
  end
end
