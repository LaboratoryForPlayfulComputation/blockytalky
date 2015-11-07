defmodule Blockytalky.RuntimeUtils do
  def btu_id do
    case System.find_executable "hostname" do
    nil -> System.get_env("HOSTNAME") || "Unknown"
    v ->
      {hostname, _} = System.cmd "hostname", []
      String.strip(hostname)
    end
  end
  @doc """
  Set hardware at runtime, then compile time backup
  $ sudo HW="btbrickpi btgrovepi" MUSIC=true blockytalky
  """
  def supported_hardware do
    system = System.get_env("HW")
    case system do
      nil ->
        Application.get_env(:blockytalky, :supported_hardware) || [:mock]
      v -> String.split() |> Enum.map(&String.to_atom/1)
    end
  end
  @doc """
  Set music support enabled at runtime, then compile time backup
  $ sudo HW="btbrickpi btgrovepi" MUSIC=true blockytalky
  """
  def music? do
    case System.get_env("MUSIC") do #set music at runtime
      "true" -> true
      "false" -> false
      nil -> Application.get_env(:blockytalky, :music, false) || false #otherwise get compile time value
    end
  end
  @doc """
  query the home directory to see if this is a coder instance. It is possible
  for someone to have a user name "coder" and this not be a coder instance, but
  this way doesn't require making a network call against <hostname>/app/auth
  """
  def coder? do
    case System.cmd("ls",["/home"]) do
      {"",_} -> false
      {s,_} -> (s |> String.contains?("coder"))
      _ -> false
    end
  end
end
