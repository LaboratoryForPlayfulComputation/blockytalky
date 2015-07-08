defmodule Blockytalky.RuntimeUtils do
  def btu_id do
    case System.find_executable "hostname" do
    nil -> System.get_env("HOSTNAME") || "Unknown"
    v ->
      {hostname, _} = System.cmd "hostname", []
      String.strip(hostname)
    end
  end
end
