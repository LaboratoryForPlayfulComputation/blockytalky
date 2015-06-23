defmodule Blockytalky.CommsModule do
  use Supervisor
  alias Blockytalky.CommsState, as: CommsState
  alias Blockytalky.LocalListener, as: LL
  require Logger
  @moduledoc """
  In charge of local and remote messaging between
  BTUs, App Inventor Apps, and music synths.

  Simply wraps the python comms module and replaces pika for now
  TODO Connect to python WS from elixir
  """
  @btu_id Application.get_env(:blockytalky, :id, "Unknown")

  ####
  #External APIs
  def start_link() do
    status = case Supervisor.start_link(__MODULE__, []) do
      {:ok, pid} -> {:ok, pid}
      {:error, reason} ->
        Logger.debug "#{inspect reason}"
        {:error, reason}
    end
  end

  def send_message(msg, to) when is_atom(to), do: send_message(msg, Atom.to_string(to))
  def send_message(msg, to) do
    case LL.get_locals_ip(to) do
      :NOIP ->
        CommsState.send_message(msg, to)
      ip ->
        #send udp message
        LL.send(msg, ip)

    end
  end

  def receive_message msg do
    #TODO broadcast on Endpoint Channel for everyone to react to.
    Logger.debug "#{inspect msg}"
  end
  ####
  #Internal functions and helpers

  ####
  # Supervisor implementation
  # CH17 Programming Elixir
  def init(_) do
    #try to connect to
    comms_children = [
      worker(CommsState, [], restart: :transient),
      worker(LL, [], restart: :transient)
    ]
    supervise comms_children, strategy: :one_for_one, max_restarts: 5, max_seconds: 1
  end
end

defmodule Blockytalky.CommsState do
  use GenServer
  require Logger
  alias Blockytalky.CommsModule, as: CM
  @moduledoc """
  keeps track of dax ws connection on init.
  """
  @dax_router Application.get_env(:blockytalky, :dax, "ws://0.0.0.0:8005/dax")
  @btu_id Application.get_env(:blockytalky, :id, "Unknown")

  def start_link() do
    dax_conn = Socket.connect! @dax_router
    msg = message_encode(@btu_id, "dax", "Subs")
    Socket.Web.send! dax_conn, {:text, msg}
    {:ok, _pid} = GenServer.start_link(__MODULE__, dax_conn, name: __MODULE__)  #return this
  end
  def send_message(msg, to) do
    dax_conn = get_dax_conn
    Socket.Web.send! dax_conn, {:text,message_encode(@btu_id, to, "Message", msg)}
  end
  def get_dax_conn, do: GenServer.call(__MODULE__,:get_dax_conn)
  defp message_encode(source, destination, channel, content \\ []) do
    ~s|{"py/object": "message.Message", "content": {"py/tuple": #{inspect content}}, "destination": "#{destination}", "channel": "#{channel}", "source": "#{source}"}|
  end
  defp message_decode({:text, msg_string}) do
    result = msg_string
              |> JSX.decode!
              |> Map.get("content")
              |> Map.get("py/tuple")
  end
  defp listen(dax_conn) do
    msg = Socket.Web.recv! dax_conn
    message_decode(msg)
    |> CM.receive_message
    listen(dax_conn)
  end
  ####
  #Genserver Implementation
  def init(dax_conn) do
    Logger.debug "dax_conn: #{inspect dax_conn}"
    listener_pid = spawn  fn -> listen(dax_conn) end
    {:ok, {dax_conn, listener_pid}}
  end
  def handle_call(:get_dax_conn, _from, state={dax_conn,_l}) do
    {:reply, dax_conn, state}
  end
  def terminate(reason, _state) do
    Logger.debug "#{inspect reason}"
    :ok
  end
end

defmodule Blockytalky.LocalListener do
  use GenServer
  require Logger
  alias Blockytalky.CommsModule, as: CM

  @udp_multicast_ip "224.0.0.1"
  @udp_multicast_delay 10_000 #milliseconds
  @udp_multicast_port 9999
  @local_ip_expiration 60_000 #milliseconds
  @btu_id Application.get_env(:blockytalky, :id, "Unknown")
  def start_link() do # () -> {:ok, pid}
    udp_conn = Socket.UDP.open! @udp_multicast_port, broadcast: true
    {:ok, _pid} =  GenServer.start_link(__MODULE__,{udp_conn, %{}}, name: __MODULE__)
  end
  def add_local(btu_name, ip), do: GenServer.cast(__MODULE__,{:add_local,btu_name,ip})
  def remove_local(btu_name), do: GenServer.cast(__MODULE__,{:remove_local,btu_name})
  def get_locals_ip(btu_name), do: GenServer.call(__MODULE__, {:get_locals_ip,btu_name})
  def get_locals_time(btu_name), do: GenServer.call(__MODULE__,{:get_locals_time, btu_name})

  defp listen udp_conn do
    Logger.debug "Listeneing for UDP messages"
    #listen for UDP messages
    {key, ip} = udp_conn |> Socket.Datagram.recv!
    #store result:
    case key do
      "ANNOUNCE:" <> value ->
        add_local(value,ip)
        spawn  fn -> expire(value) end
      "MSG:" <> value ->
        CM.receive_message(value)
    end
    listen(udp_conn)
  end
  def send(msg, socket) do
    Logger.debug "sending message via udp: #{msg} to #{inspect socket}"
    {ip,port} = socket
    GenServer.call(__MODULE__,:get_udp_conn)
    |> Socket.Datagram.send! "MSG:#{msg}", {erl_ip_to_socket_ip(ip), @udp_multicast_port}
  end
  defp announce udp_conn do
    Logger.debug "Announcing UDP status"
    #announce timestamp / ip address
    udp_conn
    |> Socket.Datagram.send! "ANNOUNCE:#{@btu_id}", {@udp_multicast_ip, @udp_multicast_port}
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
  def init({udp_conn, local_map}) do
    Logger.debug "Initializing LL"
    listener_pid  =  spawn  fn -> listen(udp_conn) end
    Logger.debug "LL listener pid: #{inspect listener_pid}"
    announcer_pid = spawn fn -> announce(udp_conn) end
    Logger.debug "LL announcer pid: #{inspect announcer_pid}"
    {:ok, {udp_conn, listener_pid, announcer_pid, local_map}}
  end
  def handle_cast({:add_local, btu_name, ip}, {udp,lis,ann,local_map}) do
    local_map = Map.put(local_map, btu_name, {ip, :calendar.universal_time})
    {:noreply,{udp,lis,ann,local_map}}
  end
  #def handle_cast(:remove_local)
  def handle_cast({:remove_local, btu_name, ip}, {udp,lis,ann,local_map}) do
    local_map = Map.delete(local_map, btu_name, ip)
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
  def handle_call(:get_udp_conn, _from, state={udp,_,_,_}), do: {:reply, udp, state}
  def terminate(reason, state={udp_conn, listener_pid, announcer_pid, _map}) do
    Logger.debug "ShuttingDown LL: #{inspect reason}"
    Socket.close udp_conn
    Process.exit(listener_pid, :restarting)
    Process.exit(announcer_pid, :restarting)
    :ok
  end
end
