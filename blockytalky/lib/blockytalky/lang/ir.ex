defmodule Blockytalky.IR do
  @moduledoc """
  The function-version of the Blockytalky.DSL as an intermediate representation
  (or library if you prefer)
  can be many lines to one "instruction"

  Mainly interoperates with the other APIs: Hardware, Music, Comms, and UserScript
  """
  ## Brick pi
  #set sensor value
  #get sensor value
  #when sensor value is <comp> <value>, do: <body>
  #when sensor value is <within | out of> range, do: <body>
  #set motor value
  #get encoder value
  ## Grove Pi
  ## Comms
  # send message <msg> to <unit>
  # when I receive message <msg> do: <body>
  ## Music
  # motif <motif name> do: <music program>
  # cue <motif> in <num> beats
  # (optional) cue <signal>
  # (optional) sync <signal>
end
