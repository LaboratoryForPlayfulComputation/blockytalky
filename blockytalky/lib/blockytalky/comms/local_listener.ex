defmodule Blockytalky.LocalListener do
  use GenServer
  require Logger
  alias Blockytalky.CommsModule, as: CM
  @moduledoc """
  Keeps track of the %{btu_id => ip_addr} map and handles listening and broadcasting
  on the UDP port.
  """
  @udp_multicast_ip "224.0.0.1"
  @udp_multicast_delay 2_000 #milliseconds
  @udp_multicast_port 8676
  @udp_unicast_port 8675
  @local_ip_expiration 30_000 #milliseconds
  def start_link() do # () -> {:ok, pid}

    {:ok, _pid} =  GenServer.start_link(__MODULE__,[], name: __MODULE__)
  end
  def add_local(btu_name, ip), do: GenServer.cast(__MODULE__,{:add_local,btu_name,ip})
  def remove_local(btu_name), do: GenServer.cast(__MODULE__,{:remove_local,btu_name})
  def get_locals_ip(btu_name), do: GenServer.call(__MODULE__, {:get_locals_ip,btu_name})
  def get_locals_time(btu_name), do: GenServer.call(__MODULE__,{:get_locals_time, btu_name})

  defp listen udp_conn do
    #Logger.debug "Listeneing for UDP messages"
    #listen for UDP messages
    {data, ip} = udp_conn |> Socket.Datagram.recv!
    #case if osc message or json message
    case data |> String.contains?("py/object") do # if it's true it's not an OSC message
      true -> msg = message_decode(data)
      _ -> msg = osc_message_decode(data, ip)
    end
     # need to decode osc messages and json messages differently
    #store result:
    case msg do
      {:announce, value} ->
        add_local(value,ip)
        spawn  fn -> expire(value) end
      {:message, value} ->
        CM.receive_message(value)
    end
    listen(udp_conn)
  end
  defp osc_message_decode(msg_string, ip) do
    packet = msg_string 
              |> OSC.decode!
    message = packet.contents
    address = message.address
    arguments = message.arguments
    {:message, {ip, address}}
  end
  defp message_decode(msg_string) do
    result = msg_string
              |> JSX.decode!
    case result |> Map.get("destination") do
      "announce" ->
        value = result
                |> Map.get("source")
        {:announce, value}
      _ ->
        content = result
                |> Map.get("content")
        sender = result
                |> Map.get("source")
        {:message, {sender, content}}
    end
  end
  def send(msg, socket) do
    Logger.debug "sending message via udp: #{msg} to #{inspect socket}"
    {ip,port} = socket
    GenServer.call(__MODULE__,:get_udp_conn)
    |> Socket.Datagram.send CM.message_encode(Blockytalky.RuntimeUtils.btu_id,erl_ip_to_socket_ip(ip),"Message", msg), {erl_ip_to_socket_ip(ip), @udp_unicast_port}
    :ok
  end
  defp announce udp_conn do
    #Logger.debug "Announcing UDP status"
    #announce timestamp / ip address
    status = udp_conn
    |> Socket.Datagram.send CM.message_encode(Blockytalky.RuntimeUtils.btu_id, "announce", "announce", ""), {@udp_multicast_ip, @udp_multicast_port}
    #sleep for a short time
    :timer.sleep(@udp_multicast_delay)
    announce(udp_conn)
  end

  defp expire(btu_name) do
    oldtime = :calendar.universal_time
    :timer.sleep(@local_ip_expiration)
    newtime = get_locals_time(btu_name)
    cond do
      newtime == :NOTIME ->
        remove_local(btu_name)
        :ok
      newtime > oldtime ->
        :ok
      true ->
        remove_local(btu_name)
        :ok
    end
  end
  defp erl_ip_to_socket_ip({a,b,c,d}), do: "#{a}.#{b}.#{c}.#{d}"
  def init(_) do
    Logger.info "Initializing #{inspect __MODULE__}"
    udp_multi_conn = Socket.UDP.open! @udp_multicast_port, broadcast: true
    udp_uni_conn = Socket.UDP.open! @udp_unicast_port, broadcast: true

    mlistener_pid  =  spawn  fn -> listen(udp_multi_conn) end
    ulistener_pid  =  spawn  fn -> listen(udp_uni_conn) end
    announcer_pid = spawn fn -> announce(udp_multi_conn) end
    {:ok, {{udp_multi_conn,udp_uni_conn}, {mlistener_pid,ulistener_pid}, announcer_pid, %{}}}
  end
  def handle_cast({:add_local, btu_name, ip}, {udp,lis,ann,local_map}) do
    local_map = Map.put(local_map, btu_name, {ip, :calendar.universal_time})
    {:noreply,{udp,lis,ann,local_map}}
  end
  #def handle_cast(:remove_local)
  def handle_cast({:remove_local, btu_name}, {udp,lis,ann,local_map}) do
    local_map = Map.delete(local_map, btu_name)
    {:noreply,{udp,lis,ann,local_map}}
  end
  def handle_call({:get_locals_ip, btu_name},_from, state={_udp,_lis,_ann,local_map}) do
    {ip,time} = Map.get(local_map,btu_name,{:NOIP, :NOTIME})
    {:reply,ip,state}
  end
  def handle_call({:get_locals_time, btu_name},_from, state={_udp,_lis,_ann,local_map}) do
    {ip,time} = Map.get(local_map,btu_name,{:NOIP,:NOTIME})
    {:reply,time,state}
  end
  def handle_call(:get_udp_conn, _from, state={udp,_,_,_}) do
    {udp_conn, _} = udp
    {:reply, udp_conn, state}
  end
  def terminate(reason, state={{udp_multi_conn, udp_uni_conn}, {mlistener_pid, ulistener_pid}, announcer_pid, _map}) do
    Logger.debug "ShuttingDown #{inspect __MODULE__}"
    Socket.close udp_multi_conn
    Socket.close udp_uni_conn
    Process.exit(mlistener_pid, :restarting)
    Process.exit(ulistener_pid, :restarting)
    Process.exit(announcer_pid, :restarting)
    :ok
  end
end
