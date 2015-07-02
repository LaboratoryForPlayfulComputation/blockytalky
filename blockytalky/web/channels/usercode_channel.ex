defmodule Blockytalky.UsercodeChannel do
  use Phoenix.Channel
  alias Blockytalky.UserState, as: US
  require Logger

  def join("usercode:" <> _any, _auth_msg, socket) do
    {:ok, socket}
  end

  def handle_in("run", {sender, :network_sync}, socket) do
    Blockytalky.Music.sync_to_parent(sender)
    {:noreply, socket}
  end
  def handle_in("stop", msg, socket) do
    #do everything we need to do with this message. probably interop with user code
    #Logger.debug "Received message: #{inspect msg}"
    US.queue_message(msg)
    push socket, "message", msg
    {:noreply, socket}
  end
  def handle_in("upload", msg, socket) do
    {:noreply, socket}
  end
  @doc """
  a progress message has the form:
  %{"type" => "run, upload, stop, info, error", "body => "body text"}
  """
  def handle_in("progress", msg, socket) do
    #echo progress to all subscribers. This lets other clients know when code is uploaded
    push socket, "progress", msg
    {:noreply, socket}
  end
end
