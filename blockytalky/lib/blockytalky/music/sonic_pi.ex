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
    tempo(120) <> maestro
  end
  def tempo(val) do
    """
    $tempo = #{val}
    """
  end
  def maestro do
    """
    # Main tempo cueing / UDP broadcasting thread
    u1 = UDPSocket.new
    live_loop :down_beat do
      use_bpm $tempo
      u1.send :network, 0, 127.0.0.1, #{@listen_port}
      sleep 0.50
      use_bpm $tempo
      cue :up_beat
      sleep 0.50
    end
    """
  end
  def maestro_network do
    """
    # Main tempo cueing / UDP broadcasting thread
    u1 = UDPSocket.new
    sync :network_sync
    live_loop :down_beat do
      use_bpm $tempo
      u1.send :network, 0, 127.0.0.1, #{@listen_port}
      sleep 0.50
      use_bpm $tempo
      cue :up_beat
      sleep 0.50
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
