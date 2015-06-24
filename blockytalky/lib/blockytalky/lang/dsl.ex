defmodule Blockytalky.DSL do
  alias Blockytalky.Lib, as: Lib
  @moduledoc """
  This is the macro-ized blockytalky language DSL
  it should be 1-1 for each of the blocks
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
