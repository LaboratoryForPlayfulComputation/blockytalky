defmodule Blockytalky.MockHW do
  alias Blockytalky.PythonQuerier, as: PythonQuerier
  require Logger

  ####
  #config
  @script_dir "#{Application.get_env(:blockytalky, Blockytalky.Endpoint, __DIR__)[:root]}/lib/hw_apis"
  @supported_hardware Application.get_env(:blockytalky, :supported_hardware)
  @port_map %{"Mock_1" => 0, "Mock_2" => 1, "Mock_3" => 2, "Mock_4" => 3}
  ####
  # External API

  def get_sensor_value(port_id), do: PythonQuerier.run_result(:mock, :get_sensor_value,[get_port_num(port_id)])
  def set_sensor_type(port_id, value), do: PythonQuerier.run(:mock, :set_sensor_type, [get_port_num(port_id), value])
  def get_port_num(port_id), do: Map.get(@port_map, port_id)
end
