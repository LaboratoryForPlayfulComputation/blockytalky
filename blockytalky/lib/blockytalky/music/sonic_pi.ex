defmodule Blockytalky.SonicPi do
  @moduledoc """
  This is a module completely of "functions-as-data" sonicpi programs.
  to achieve subdivisions sleep in % amounts relative to beats.
  e.g.
  to rest for 1/8th + 1/16th and then play a 16th note, it would look like:
    sync :beat1
    sleep 0.75
    play <pitch>
  """
  @listen_port  Application.get_env(:blockytalky, :music_port, 9090)
  ####
  #System-y functions
  def public_cues do
    [:down_beat, :up_beat, :beat1, :beat2, :beat3, :beat4]
  end
  def init do
    tempo(120) <> maestro_beat_pattern(false,4)
  end
  def tempo(val) do
    """
    $tempo = #{val}
    """
  end
  def maestro_beat_pattern(network, beats_per_measure) do
    sync_to_network = if network, do: "sync :network_sync", else: "#"
    beat_signaling = cond do
      beats_per_measure > 2 ->
      Enum.reduce(2..beats_per_measure,"",fn(x,acc) -> """
        sync :down_beat
        cue :beat#{x}
        """
      end)
      true ->
        "#"
      end
    #return program:
    """
    u1 = UDPSocket.new
    #{sync_to_network}
    # Main tempo cueing / UDP broadcasting thread
    live_loop :down_beat do
      use_bpm $tempo
      sleep 0.50
      use_bpm $tempo
      cue :up_beat
      sleep 0.50
    end
    live_loop :beat_pattern do
      sync :down_beat
      cue  :beat1
      u1.send :network_sync, 0, '127.0.0.1', #{@listen_port}
      #{beat_signaling}
    end

    """
  end
  # stop motif with $motif_name.kill
  def def_motif(motif_name, body_program) do
    """
    $#{motif_name} = define :#{motif_name} do
      #{body_program}
    end
    """
  end
  def start_motif(motif_name, sync \\ :down_beat)  do
    """
    sync #{sync}
    $#{motif_name}_thread = in_thread(name: :#{motif_name}_thread) do
      $#{motif_name}.() #lambda
    end
    """
  end
  def loop_motif(motif_name, sync \\ :down_beat) do
    """
    sync #{sync}
    $#{motif_name}_thread = in_thread(name: :#{motif_name}_thread) do
      loop do
        $#{motif_name}.() #lambda
      end
    end
    """
  end
  def stop_motif(motif_name) do
    """
    $#{motif_name}.kill
    """
  end
  def cue(cue_flag) do
    """
    cue #{cue_flag}
    """
  end
  ####
  #User-y functions, e.g. motif body pieces
end
