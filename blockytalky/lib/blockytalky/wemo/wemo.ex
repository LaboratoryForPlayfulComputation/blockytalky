defmodule Blockytalky.WeMo do
  def device_turn_on(device_name) do
    device_set_state(device_name, :on)
  end

  def device_turn_off(device_name) do
    device_set_state(device_name, :off)
  end

  def device_toggle(device_name) do
    device_set_state(device_name, :toggle)
  end

  def device_set_state(device_name, state) do
    if state in [:on, :off, :toggle] do
      System.cmd("wemo", ["switch", device_name,  to_string(state)])
    end
  end
end
