defmodule Blockytalky.UserCodeChannel do
  use Phoenix.Channel
  alias Blockytalky.UserState, as: US
  require Logger


  def join("uc:" <> _any, _auth_msg, socket) do
    {:ok, socket}
  end

  def handle_in("run", _, socket) do
    US.execute_user_code();
    {:noreply, socket}
  end
  def handle_in("stop", _, socket) do
    US.stop_user_code
    Blockytalky.HardwareDaemon.stop_signal
    Blockytalky.Music.stop_signal
    {:noreply, socket}
  end
  def handle_in("upload", %{"body" => map}, socket) do
    spawn fn ->
      US.upload_user_code(map)
      backup_code(map)
    end
    {:noreply, socket}
  end
  def handle_in("download", _ , socket) do
    map = GenServer.call(US,:get_user_code)
    {:reply, {:ok, map}, socket}
  end
  def handle_in("select_sample", %{"body" => _sample_name}, socket) do
    {:noreply, socket}
  end
  def handle_in("upload_sample", %{"body" => _sample}, socket) do
    {:noreply, socket}
  end
  @doc """
  a progress message has the form:
  %{"type" => "run, upload, stop, info, error", "body => "body text"}
  """
  def handle_in("progress", msg, socket) do
    #echo progress to all subscribers.
    #This lets other clients know when code is uploaded, etc.
    push socket, "progress", msg
    {:noreply, socket}
  end
  def handle_in("error", msg, socket) do
    push socket, "error", msg
    {:noreply, socket}
  end

  ####
  #Internal API
  defp backup_code(map) do
    #backup usercode (code and xml representation)
    {{y,mo,d},{h,mi,s}} = :calendar.universal_time
    [y | _] =  :io_lib.format('~4..0B~n', [y]) #format to 4 digits
    [mo,d,h,mi,s] = for x <- [mo,d,h,mi,s] do
      [val | _ ] = :io_lib.format('~2..0B~n', [x]) #format to 2 digits
      val
    end
    file_name = Enum.join([Blockytalky.RuntimeUtils.btu_id,y,mo,d,h,mi,s], "_") <> ".json"
    File.mkdir(Application.get_env(:blockytalky,:user_code_dir))
    case File.write("#{Application.get_env(:blockytalky,:user_code_dir)}/#{file_name}", JSX.encode!(map) |> JSX.prettify!) do
      {_, reason} -> Blockytalky.Endpoint.broadcast! "uc:command", "error",  %{body: reason}
      _           -> Blockytalky.Endpoint.broadcast! "uc:command", "progress",  %{body: "Code uploaded!"}
    end
  end
end
