defmodule Blockytalky.WeMo do
  def device_turn_on(device_name) do
    cmd_output = System.cmd("wemo", ["switch", device_name,  "on"])
  end

  def device_turn_off(device_name) do
    cmd_output = System.cmd("wemo", ["switch", device_name,  "off"])
  end

  def device_toggle(device_name) do
    cmd_output = System.cmd("wemo", ["switch", device_name,  "toggle"])
  end

  def device_set_state(device_name, state) do
    cmd_output = System.cmd("wemo", ["switch", device_name,  to_string(state)])
  end
end
