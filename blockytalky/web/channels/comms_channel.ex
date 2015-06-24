defmodule Blockytalky.CommsChannel do
  use Phoenix.Channel
  require Logger
  ####
  #Channel GenServer implementation
  #pattern match on param 1, a string like "topic:subtopic"
  def join("comms:" <> _any, _auth_msg, socket) do
    Logger.debug "User joined socket: #{inspect socket}"
    {:ok, socket}
  end

  def handle_in("network_sync", {sender, :network_sync}, socket) do
    #tell Music module we got a network sync message
    #TODO see if this has too much lag!
    Blockytalky.Music.sync_to_parent(sender)
    {:noreply, socket}
  end
  def handle_in("message", msg, socket) do
    #do everything we need to do with this message. probably interop with user code
    push socket, "message", msg
    {:noreply, socket}
  end
end
