defmodule Blockytalky.Music do
  use GenServer
  require Logger
  alias Blockytalky.SonicPi, as: SonicPi
  @moduledoc """
  Motifs are defined as Sonic pi DSL strings
  Motifs can be played [in loops|one-shots] in named threads that can be started
  (in_thread) or killed ($threadvar.kill)
  """
  @sonicpi_port 4557
  def eval_port, do: Application.get_env(:blockytalky, :music_eval_port, 5050)
  ####
  #External API
  def listen_port do
    Application.get_env(:blockytalky, :music_respond_port, 9091)
  end
  def stop_signal do
    send_music_program(SonicPi.stop_motif, false)
  end
  def listen(udp_conn) do
    {data, ip} = udp_conn
      |> Socket.Datagram.recv!
    case JSX.decode(data) do
      {:ok, map} ->
        message = Map.get(map,"message")
        to = Map.get(map,"to")
        Blockytalky.CommsModule.send_message(message,to)
      _ ->
        :ok
    end
    listen(udp_conn)
  end
  @doc """
  Sends a music program(string) to the sonic pi instance running on local host
  see Blockytalky.SonicPi for programs API
  ## Example
      iex> Blockytalky.Music.send_music_program(Blockytalky.SonicPi.cue(:my_cue))
  """
  def send_music_program(program, use_eval_port \\ false) do
    send_music_program(GenServer.call(__MODULE__,:get_udp_conn),program, use_eval_port)
  end
  def send_music_program(udp_conn, program, use_eval_port) do
    #pack program as osc message
    if use_eval_port do
      udp_conn
      |> Socket.Datagram.send!(program, {"127.0.0.1", eval_port})
    else #this case is used for initializing before the eval port is listening
      m = {:message, '/run-code',[String.to_char_list(program)]}
          |> :osc_lib.encode
      #send program via udp to sonic pi port
      udp_conn
      |> Socket.Datagram.send!( m, {"127.0.0.1", @sonicpi_port})
    end
  end
  def get_samples_map do
    GenServer.call(__MODULE__,:get_samples_map)
  end
  def get_sample(sample_num) do
    Map.get(get_samples_map, sample_num)
  end
  def set_sample(sample_num, file_name) do
    GenServer.cast(__MODULE__,{:set_sample, sample_num, file_name})
  end
  def get_saved_samples do
    File.mkdir "data/samples"
    case File.ls "data/samples" do
      {:ok, files} -> files
      {:error, _} -> []
    end
  end
  ####
  #Internal API

  ####
  # GenServer Implementation
  # CH. 16
  def start_link() do
    {:ok, _pid} = GenServer.start_link(__MODULE__,[], name: __MODULE__)
  end
  def init(_) do
    Logger.info "Initializing #{inspect __MODULE__}"
    udp_conn = Socket.UDP.open! listen_port, broadcast: true
    _ = spawn fn -> listen(udp_conn) end
    _task = Task.async fn ->
      :timer.sleep(15_000) #TODO: replace with ping back from sonic
      send_music_program(udp_conn, SonicPi.init, false)
    end

    # read last loaded samples
    File.mkdir("data")
    File.touch!("data/samples.json") #make the file if it doesn't exist
    samples_map = case File.read!("data/samples.json") |> JSX.decode do
      {:ok, map} -> map
      _          -> %{}
    end
    {:ok, {udp_conn, samples_map}}
  end
  def handle_call(:get_udp_conn, _from, s={u,_m}), do: {:reply, u, s}
  def handle_call(:get_samples_map, _from, s={_u,m}), do: {:reply,m,s}
  def handle_cast({:set_sample, sample_num, file_name}, _from, {u,m}) do
    {:noreply,{u,Map.put(m,sample_num,file_name)}}
  end
  def terminate(_reason, _state) do
    Logger.info "Terminating #{inspect __MODULE__}"
    :ok
  end
end
