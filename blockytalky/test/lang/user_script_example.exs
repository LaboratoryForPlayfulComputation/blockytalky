defmodule Blockytalky.UserScriptExample
  use Blockytalky.DSL
  @moduledoc """
  this is the cummulative example of what the code Blockly
  generates should look like. everything the kids block program
  gets wrapped inside the blockytalky do ... end
  with keywords: once, while, run, motif, send, say, set, value
  with options: to, on, of, duration
  and the reserved atoms from the Music and Hardware modules

  The challenge so far seems to be elixir's lexxer / parser is not letting me
  be creative with the syntax. Before I can macro-ize it, it has to be valid
  elixir code. This is really finicky in some cases, usually when mixing in atoms and numbers
  """
  once :start do
    counter = 0
    item = 0 #alternative could be set item, to: 0
    cue :my_motif
    cue :my_motif, on: :beat1
    cue :my_motif, after_waiting: {3, :beats}
    cue :my_motif, after_waiting: {3.5, :beats}
    cue :my_motif, after_waiting: {5, :measures}, on: :beat2
    cue :your_motif to: "walle" on: :beat3 after_waiting: {5, :measures}
    #this is valid: it will wait 2 beats to cue, then wait for the beat# to play
    cue :my_motif in: 2 :beats on: :beat1
  end
  once :PORT_A > 100_000 do
    say "debug message here"
    send "hello" to: "marceline"
  end
  once :PORT_1 > 10 do
    set :MOTOR_1 to: 100
    set item to: value of: :PORT_3
  end
  run :continuously do
    counter = counter + 1
  end
  once :receive "hello" do
    send "goodbye" to: "jake"
  end
  motif :my_motif do
    play [:C5, :E5, :G5] duration: 3 :beats
    play :F6 duration: 1 :beat
    rest duration: 3 beats
  end
  motif :my_loop do
    loop duration: 16 :measures do
      play [:C5, :E5, :G5] duration: 2 :beats
      play [:C5, :F5, :A5] duration: 2 :beats
      play [:C5, :E5, :A5] duration: 2 :beats
      play [:G5, :B5, :D6, :F6] duration: 2 :beats
    end
  end
