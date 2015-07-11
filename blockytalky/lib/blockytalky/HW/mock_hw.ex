defmodule Blockytalky.MockHW do
  alias Blockytalky.PythonQuerier, as: PythonQuerier
  require Logger
  def port_map, do: %{"MOCK_1" => 0, "MOCK_2" => 1, "MOCK_3" => 2, "MOCK_4" => 3}
  ####
  # External API

  def get_sensor_value(port_id) do
    case PythonQuerier.run_result(:mock, :get_sensor_value,[get_port_num(port_id)]) do
      {_, value} -> value
      v -> v
    end
  end
  def set_sensor_type(port_id, value), do: PythonQuerier.run(:mock, :set_sensor_type, [get_port_num(port_id), value])
  def get_port_num(port_id), do: Map.get(port_map, port_id)
end
