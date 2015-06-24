defmodule Blockytalky.Music do
  use GenServer
  require Logger
  alias Blockytalky.SonicPi, as: SonicPi
  @moduledoc """
  Motifs are defined as Sonic pi lambda's
  Motifs can be played [in loops|one-shots] in named threads that can be started
  (in_thread) or killed ($threadvar.kill)
  """
  @sonicpi_port 4557
  @listen_port  Application.get_env(:blockytalky, :music_port, 9090)
  ####
  #External API
  def add_child(btu_id) do
    GenServer.cast(__MODULE__, {:add_dependant, btu_id})
  end
  def set_parent(parent_id) do
    spawn send_music_program(SonicPi.maestro_parent) #prep sonic pi vm to sync
    GenServer.cast(__MODULE__, {:set_parent, parent_id})
  end
  def sync_to_parent(parent_id) do
    if parent_id == get_parent, do: send_music_program(SonicPi.cue(:network))
  end
  ####
  #Internal API
  def send_music_program(program) do
    #send program via udp to sonic pi port
    GenServer.call(__MODULE__, :get_udp_conn)
    |> Socket.Datagram.send! program, {"127.0.0.1", @sonicpi_port}
  end
  #all messages come from sonic_pi, any message from another BTU will come from the comms module
  defp listen(udp_conn) do
    #listen for udp message
    {data, ip} = udp_conn |> Socket.Datagram.recv!
        Logger.debug "Got message from sonicpi: #{inspect data}"
    case data do
      :network_sync ->
        #send network signal to children
        get_children
        |> Enum.map(fn(child) -> CommsModule.send_message(:network_sync,child) end)
    end
    listen(udp_conn)
  end
  defp get_parent do
    GenServer.call(__MODULE__,:get_parent)
  end
  defp get_children do
    GenServer.call(__MODULE__, :get_children)
  end
  ####
  # GenServer Implementation
  # CH. 16
  def start_link() do
    udp_conn = Socket.UDP.open! @udp_multicast_port, broadcast: true
    Logger.info "Starting #{inspect __MODULE__}"
    {:ok, _pid} = GenServer.start_link(__MODULE__, udp_conn)
  end
  def init(udp_conn) do
    send_music_program(SonicPi.init)
    listener_pid = spawn listen(udp_conn)
    music_dependants = []
    maestro_parent = :self
    {:ok, {udp_conn, listener_pid, music_dependants, maestro_parent}}
  end
  def handle_call(:get_parent, _from, s={_,_,_,parent}), do: {:reply, parent, s}
  def handle_call(:get_children, _from, s={_,_,c,_}), do: {:reply, c, s}
  def handle_call(:get_udp_conn, _from, s={u,_,_,_}), do: {:reply, u, s}
  def handle_cast({:add_child, btu_id}, _from, s={u,l,c,p}), do: {:noreply,{u,l,c ++ [btu_id]}}
  def terminate(_reason, {_udp_conn, listener_pid, _music_dependants, _maestro_parent}) do
    Process.exit(listener_pid, :restarting)
    Logger.info "Terminating #{inspect __MODULE__}"
    :ok
  end
end
