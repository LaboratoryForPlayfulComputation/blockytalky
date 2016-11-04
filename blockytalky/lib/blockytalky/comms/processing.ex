defmodule Blockytalky.Processing do
  use GenServer
  require Logger

  def listen_port do
    Application.get_env(:blockytalky, :music_respond_port, 9091)
  end

  def send_osc_message(ip, to_port, name, args) do
  	kind = :message
  	udp_conn = Socket.UDP.open! listen_port, broadcast: true
  	message = {kind, name, [String.to_char_list(args)]} |> :osc_lib.encode
	Socket.Datagram.send(udp_conn, message, {ip, to_port})
  end

end

Blockytalky.Processing.send_osc_message('127.0.0.1', 12000, '/test', "blah")