#Author: Annie Kelly
#Date: 11/03/16
#Module for simplifying OSC communication between BT and other apps

defmodule Blockytalky.Processing do
  use GenServer
  require Logger

  def listen_port do
    Application.get_env(:blockytalky, :music_respond_port, 9091)
  end

  def send_osc_message(ip, to_port, name, params) do
    udp_conn = Socket.UDP.open! 9999, broadcast: true
    args = List.flatten params
    blah = ['one', 'two', 1.0, 2.0, 'three']
    blah = ["hi", "hi", "hi", 1.0]
    IO.inspect args
    IO.inspect blah
    {reply, message} = %OSC.Message{address: name, arguments: args} |> OSC.encode
    #message = {:message, name, args} |> :osc_lib.encode
    Socket.Datagram.send(udp_conn, message, {ip, to_port})
    Socket.close udp_conn
  end

  def recv_osc_message do
    IO.puts("Receiving OSC messages is not yet implemented")
  end

end