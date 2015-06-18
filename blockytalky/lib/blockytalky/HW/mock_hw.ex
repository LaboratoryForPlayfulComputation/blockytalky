defmodule Blockytalky.MockHW do
  alias Blockytalky.PythonQuerier, as: PythonQuerier
  require Logger

  ####
  #config
  @script_dir "#{Application.get_env(:blockytalky, Blockytalky.Endpoint, __DIR__)[:root]}/lib/hw_apis"
  @supported_hardware Application.get_env(:blockytalky, :supported_hardware)

  ####
  # External API

  def get_sensor_value(port_num) when port_num < 4, do: PythonQuerier.run_result(:mock, :get_sensor_value,[port_num])
  def set_sensor_type(port_num, value), do: PythonQuerier.run(:mock, :set_sensor_type, [port_num, value])

end
