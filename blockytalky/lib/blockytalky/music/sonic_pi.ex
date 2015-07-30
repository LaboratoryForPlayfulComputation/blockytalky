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
  def music_resp_port, do: Application.get_env(:blockytalky, :music_respond_port, 9091)
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
    set_volume! #{value}
    """
  end
  def tempo(val) do
    """
    $tempo = #{val}
    """
  end
  def set_synth(synth) do
    """
    $synth = #{inspect synth}
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
          msg = $u2.recvfrom_nonblock(1024) # "["hostname,tempo",[..args..]]"
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
              if $next_beat != nil && $next_beat.alive?
                $next_beat.kill
              end
              cue :down_beat
              beat_num = beat[-1,1].to_i
              $next_beat = in_thread do
                loop_num = 0
                until loop_num > 4 do
                  sleep 0.96
                  next_num = (beat_num % #{beats_per_measure}) + 1
                  cue ("beat" + next_num.to_s ).to_sym
                  beat_num = beat_num + 1
                  loop_num = loop_num + 1
                end
              end
            end
            synced = true
          end
          sleep 1.0 / 128.0
        rescue
          sleep 1.0 / 64.0
          next
        end
      end
      """
    end
    beat_signaling = cond do
      beats_per_measure > 1 ->
      Enum.reduce(1..beats_per_measure,"",fn(x,acc) ->
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
      #{if parent != false, do: sync_to_network, else: beat_signaling}
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
        rescue #IO::WaitReadable
          sleep 1.0 / 64.0
          next
        end
      end
    end
    """
  end
  def start_motif(body_program, opts \\ [])  do
    loop = Keyword.get(opts,:loop,false)
    """
    $keep_looping = #{loop}
    $cueued = true
    define :next_motif do
      $cueued  = false
      #{body_program}
    end
    if $my_motif_thread == nil || $my_motif_thread.alive? == false
      $my_motif_thread = in_thread do
        loop do
          use_bpm $tempo
          next_motif
          break if ! $keep_looping && ! $cueued
        end
      end
    end
    """
  end
  def stop_motif() do
    """
    $my_motif_thread.kill
    if $next_beat != nil && $next_beat.alive?
      $next_beat.kill
    end
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
    |> String.replace("#","s") #elixir atoms don't support #s so sharps are s'
    #return:
    """
    use_bpm $tempo
    if $synth != nil
      use_synth $synth
    end
    play #{p}, sustain: #{duration}, amp: $amp
    """
  end
  def send_music_message(message, to) do
    """
    if $u1 != nil && ! $u1.closed?
      $u1.send "{\\"message\\":\\"#{message}\\", \\"to\\":\\"#{to}\\"}", 0, '127.0.0.1', #{music_resp_port}
    end
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
    t = t * 0.995
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
  def with_fx(fx) do
    {
    """
    with_fx #{inspect fx} do
    """,
    """
    end
    """}
  end

end
