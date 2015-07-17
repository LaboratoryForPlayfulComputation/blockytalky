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
  def listen_port, do:  Application.get_env(:blockytalky, :music_port, 9090)
  def eval_port, do: Application.get_env(:blockytalky, :music_eval_port, 5050)
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
  def maestro_beat_pattern(parent, beats_per_measure) do
    sync_to_network = case parent do
      false -> "#"
      name -> #Ruby code to listen until the parent sends a sync message
      """
      loop do
        begin
          msg = $u2.recvfrom_nonblock(2048) # "[hostname,tempo[..args..]]"
          msg_payload = msg[0].split(",")
          host=msg_payload[0]
          t=msg_payload[1]
          if(host == $parent)
            $tempo = t
            break
          end
        rescue
          sleep 1.0 / 64.0
          next
        end
      end
      """
    end
    beat_signaling = cond do
      beats_per_measure > 2 ->
      Enum.reduce(2..beats_per_measure,"",fn(x,acc) ->
        acc
        <>
        """
        sync :down_beat
        cue :beat#{x}
        """
      end)
      true ->
        "#"
      end
    #return program:
    """
    if $u1 != nil && !$u1.closed?
      $u1.close
    end
    if $u2 != nil && !$u2.closed?
      $u2.close
    end
    if $u3 != nil && !$u3.closed?
      $u3.close
    end
    $u1 = UDPSocket.new
    $u2 = UDPSocket.new
    $u2.bind("127.0.0.1", #{listen_port})
    # Main tempo cueing / UDP broadcasting thread
    live_loop :down_beat do
      #{sync_to_network}
      use_bpm $tempo
      sleep 0.50
      use_bpm $tempo
      cue :up_beat
      sleep 0.50
    end
    live_loop :beat_pattern do
      sync :down_beat
      cue  :beat1
      $u1.send "#{Blockytalky.RuntimeUtils.btu_id},\#{$tempo\}", 0, '224.0.0.1', #{listen_port}
      #{beat_signaling}
    end
    #the default sonic pi eval port is pretty slow on raspberry pi
    #this loop listens on a different port to speed it up
    $u3 = UDPSocket.new
    $u3.bind("127.0.0.1", #{eval_port})
      live_loop :eval_loop do
        begin
          program, addr = $u3.recvfrom_nonblock(65655)
          if addr[3] == "127.0.0.1" # only accept eval messages from localhost, arbitrary eval is bad, m'kay.
            eval(program)
          end
          sleep 1.0 / 128.0
        rescue IO::WaitReadable
          sleep 1.0 / 128.0
          next
        end
      end
    """
  end
  # stop motif with $motif_name.kill
  def def_motif(motif_name, body_program) do
    """
    define :my_motif do
      use_bpm $tempo
      #{body_program}
    end
    """
  end
  def start_motif(motif_name)  do
    """
    $my_motif_thread = in_thread(name: :my_motif_thread) do
      my_motif #lambda
    end
    """
  end
  def loop_motif(motif_name, sync \\ :down_beat) do
    """
    sync #{sync}
    $my_motif_thread = in_thread(name: :my_motif_thread) do
      loop do
        my_motif#lambda
      end
    end
    """
  end
  def stop_motif(motif_name) do
    """
    my_motif_thread.kill
    """
  end
  def cue(cue_flag) do
    """
    cue #{cue_flag}
    """
  end
  ####
  #User-y functions, e.g. motif body pieces
  @doc """
  The SonicPi specific DSL code-string for playing a pitch.
  """
  def play_synth(pitch, duration) do
    p = case pitch do
      n when is_integer(n) -> n
      ":" <> s -> pitch
      non_atom -> ":" <> non_atom
    end
    "play #{p}, sustain: #{duration}"
  end
  @doc """
  TODO: Make this sensitive to the beats per measure set by the user (when they get that option)
  """
  def sleep(duration), do: sleep(duration, :beats)
  def sleep(duration,units) do
    t = case units do
      :beats -> duration
      :measures -> duration * 4
    end
    "sleep #{t}"
  end
  def sync(flag) do
    "sync :#{flag}"
  end
end
