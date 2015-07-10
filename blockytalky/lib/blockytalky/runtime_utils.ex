defmodule Blockytalky.RuntimeUtils do
  def btu_id do
    case System.find_executable "hostname" do
    nil -> System.get_env("HOSTNAME") || "Unknown"
    v ->
      {hostname, _} = System.cmd "hostname", []
      String.strip(hostname)
    end
  end
  def supported_hardware do
    System.get_env("HW")
    || Application.get_env(:blockytalky, :supported_hardware)
    || [:mock]
  end
end
