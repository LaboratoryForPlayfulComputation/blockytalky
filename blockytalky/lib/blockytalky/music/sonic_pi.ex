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
    set_amp(50) <> tempo(120) <> maestro_beat_pattern(false,4)
  end
  @doc """
  Takes a value between 0 and 100 and converts it to one between 0 and 5
  """
  def set_amp(value) do
    value = value / 20
    """
    $amp = #{value}
    """
  end
  def tempo(val) do
    """
    $tempo = #{val}
    """
  end
  @doc """
  takes the name of the btu to sync to or false as a first param
  takes beats per measure >= 1 as a second param.
  When syncing to a parent btu, it will listen for a first message,
  then it will keep track of time internally for one measure
  #the default sonic pi eval port is pretty slow on raspberry pi
  #this loop listens on a different port to speed it up
  """
  def maestro_beat_pattern(parent, beats_per_measure) do
    sync_to_network = case parent do
      false -> "#"
      name -> #Ruby code to listen until the parent sends a sync message
      """
      synced = false
      until synced  do
        begin
          synced = false
          msg = $u2.recvfrom_nonblock(2048) # "["hostname,tempo",[..args..]]"
          msg_payload = msg[0].split(",")
          host = msg_payload[0]
          if(host == "#{name}")
            t = msg_payload[1]
            beat = msg_payload[2]
            $tempo = t.to_f
            use_bpm $tempo
            $u1.send "#{Blockytalky.RuntimeUtils.btu_id},\#{$tempo\},\#{beat\}", 0, '224.0.0.1', #{listen_port}
            cue beat.to_sym
            if beat != "up_beat"
              cue :down_beat
            end
            synced = true
          end
        rescue
          sleep 1.0 / 128.0
          next
        end
      end
      """
    end
    beat_signaling = cond do
      beats_per_measure > 1 ->
      Enum.reduce(1..(beats_per_measure-1),"",fn(x,acc) ->
        acc
        <>
        """
        cue :down_beat
        cue :beat#{x}
        $u1.send "#{Blockytalky.RuntimeUtils.btu_id},\#{$tempo\},beat#{x}", 0, '224.0.0.1', #{listen_port}
        sleep 0.5
        cue :up_beat
        $u1.send "#{Blockytalky.RuntimeUtils.btu_id},\#{$tempo\},up_beat", 0, '224.0.0.1', #{listen_port}
        sleep 0.5
        """
      end)
      true ->
        "#"
      end
    #return program:
    """
    use_debug false
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
    $u2.bind("0.0.0.0", #{listen_port})
    # Main tempo cueing / UDP broadcasting thread
    live_loop :beat_pattern do
      use_bpm $tempo
      #{if parent != nil, do: sync_to_parent, else: beat_signaling}
    end

    $u3 = UDPSocket.new
    $u3.bind("127.0.0.1", #{eval_port})
    if $eval_thread != nil && $eval_thread.alive?
      $eval_thread.kill
    end
    $eval_thread = in_thread do
      loop do
        begin
          program, addr = $u3.recvfrom_nonblock(65655)
          eval(program)
          sleep 1.0 / 64.0
        rescue IO::WaitReadable
          sleep 1.0 / 64.0
          next
        end
      end
    end
    """
  end
  def start_motif(body_program)  do
    """
    $next_motif = define :next_motif do
      #{body_program}
    end
    if $current_motif == nil
      $current_motif = $next_motif
      $next_motif = nil
    end
    if $my_motif_thread == nil || $my_motif_thread.alive? == false
      $my_motif_thread = in_thread do
        until $current_motif == nil do
          use_bpm $tempo
          $current_motif.()
          $current_motif = $next_motif
          $next_motif = nil
        end
      end
    end
    """
  end
  def loop_motif(body_program) do
    """
    $next_motif = define :next_motif do
      #{body_program}
    end
    if $current_motif == nil
      $current_motif = $next_motif
      $next_motif = nil
    end
    if $my_motif_thread == nil || $my_motif_thread.alive? == false
      $my_motif_thread = in_thread do
        loop do
          use_bpm $tempo
          $current_motif.()
          if $next_motif != nil
            $current_motif = $next_motif
            $next_motif = nil
          end
        end
      end
    end
    """
  end
  def stop_motif() do
    """
    $my_motif_thread.kill
    $current_motif = nil
    $next_motif = nil
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
  def play_synth(pitches, duration) when is_list(pitches) do
    pitches
    |> Enum.map(fn pitch -> play_synth(pitch, duration) end)
    |> Enum.join("\n")
  end
  def play_synth(pitch, duration) do
    p = case pitch do
      n when is_integer(n) -> n
      ":" <> s -> pitch
      non_atom -> ":" <> non_atom
    end
    """
    use_bpm $tempo
    play #{p}, sustain: #{duration}, amp: $amp
    """
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
    t = t * 0.99
    """
    use_bpm $tempo
    sleep #{t}
    """
  end
  def trigger_sample(sample) do
    """
    use_bpm $tempo
    sample #{inspect sample}, amp: $amp
    """
  end
  def sync(flag) do
    "sync :#{flag}"
  end

end
