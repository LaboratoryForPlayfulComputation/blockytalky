
defmodule Blockytalky.DaxListener do
  use GenServer
  require Logger
  alias Blockytalky.CommsModule, as: CM
  @moduledoc """
  keeps track of dax ws connection and has a listener process to push to the
  CommsModule receive channel
  """
  @dax_router Application.get_env(:blockytalky, :dax, "ws://0.0.0.0:8005/dax")

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)  #return this
  end
  def send_message(msg, to) do
    try do #the genserver might not be running
      dax_conn = get_dax_conn
      Socket.Web.send dax_conn, {:text,CM.message_encode(Blockytalky.RuntimeUtils.btu_id, to, "Message", msg)}
    rescue
      _ -> :ok
    end
  end
  def get_dax_conn, do: GenServer.call(__MODULE__,:get_dax_conn)
  defp message_decode({:text, msg_string}) do
    msg = msg_string
              |> JSX.decode!
    content = msg
              |> Map.get("content")
              |> Map.get("py/tuple")
    sender  = msg
              |> Map.get("source")
    {sender, content}
  end
  defp listen(dax_conn) do
    msg = Socket.Web.recv! dax_conn
    spawn fn ->
      message_decode(msg)
      |> CM.receive_message
    end
    listen(dax_conn)
  end
  defp observer() do
    :timer.sleep(60_000)
    case get_dax_conn do
      nil ->
        try do
          dax_conn = connect
          GenServer.cast(__MODULE__,{:set_dax_conn, dax_conn})
        rescue
          _ ->  :ok
        end
      _ ->
        :ok
    end
    observer()
  end
  ####
  #Genserver Implementation
  def init(_) do
    Logger.info "Initializing #{inspect __MODULE__}"
    try do
      dax_conn = connect
      Logger.debug "connected to dax!"
      msg = CM.message_encode(Blockytalky.RuntimeUtils.btu_id, "dax", "Subs")
      Socket.Web.send! dax_conn, {:text, msg}
      Logger.debug "dax_conn: #{inspect dax_conn}"
      listener_pid = spawn  (fn -> listen(dax_conn) end)
      _ = spawn (fn -> observer() end)
      {:ok, {dax_conn, listener_pid}}
    rescue
      _ -> :ignore
    end
  end
  ####
  #private API
  defp connect do
    Task.async fn -> Socket.connect! @dax_router end
    |> Task.await 10_000 #10 second timeout for waiting to connect
  end
  def handle_call(:get_dax_conn, _from, state={dax_conn,_l}) do
    {:reply, dax_conn, state}
  end
  def handle_cast({:set_dax_conn, conn}, {dax_conn, l}) do
    {:noreply, {conn, l}}
  end
  def terminate(reason, _state) do
    Logger.debug "#{inspect reason}"
    :ok
  end
end
