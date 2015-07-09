defmodule Blockytalky.CommsModule do
  use Supervisor
  alias Blockytalky.DaxListener, as: DL
  alias Blockytalky.LocalListener, as: LL
  require Logger
  @moduledoc """
  In charge of local and remote messaging between
  BTUs, App Inventor Apps, and music synths.
  """
  @btu_id Blockytalky.RuntimeUtils.btu_id

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
  @doc """
  The primary API function all the other modules can call. Will try to use UDP
  broadcast first, but then defaults to remote server if it cannot find the ip
  ## Example
      iex> Blockytalky.CommsModule.send_message("hello",Application.get_env(:blockytalky, :id, "Unknown")) #loopback, send to self
  """
  def send_message(msg, to) when is_atom(to), do: send_message(msg, Atom.to_string(to))
  def send_message(msg, to) do
    case LL.get_locals_ip(to) do
      :NOIP ->
        DL.send_message(msg, to)
      ip ->
        #send udp message
        LL.send(msg, ip)
    end
  end
  @doc """
  This is the public API `message out` function. It publishes on a Blockytalky.Endpoint channel for other modules to listen to.
  TODO Make this function broadcast to a globally known channel that can be listened on.
  """
  def receive_message msg do
    Logger.debug "received message: #{inspect msg}"
    case msg do
      {sender, :network_sync} ->
        Blockytalky.Endpoint.broadcast! "comms:sync", "network_sync",  %{body: msg}
      _ ->
        {sender, body} = msg
        US.queue_message(body)
        Blockytalky.Endpoint.broadcast! "comms:message", "message",  %{body: body}
    end
  end
  ####
  #Internal functions and helpers
  @doc """
  packs the python message.py style json object for the sake of backwards compat.
  """
  def message_encode(source, destination, channel, content \\ []) do
    ~s|{"py/object": "message.Message", "content": {"py/tuple": #{inspect content}}, "destination": "#{destination}", "channel": "#{channel}", "source": "#{source}"}|
  end
  ####
  # Supervisor implementation
  # CH17 Programming Elixir
  def init(_) do
    #try to connect to
    comms_children = [
      worker(DL, [], restart: :transient),
      worker(LL, [], restart: :transient)
    ]
    supervise comms_children, strategy: :one_for_one, max_restarts: 5, max_seconds: 1
  end
end
