defmodule Blockytalky.DSL do
  alias Blockytalky.UserScript, as: US
  alias Blockytalky.BrickPi, as: BP
  alias Blockytalky.Music, as: Music
  alias Blockytalky.SonicPi, as: SP
  alias Blockytalky.CommsModule, as: CM
  alias Blockytalky.CommsChannel, as: CC
  @moduledoc """
  The function-version of the Blockytalky.DSL as an intermediate representation
  (or library if you prefer)
  can be many lines to one "instruction"

  Mainly interoperates with the other APIs: Hardware, Music, Comms, and UserScript
  We ``should`` do type checking / correctness checking here!
  """
  ## Macros
  @doc """
  this initialize macro sets up the init function (for start_link), and a
  private run function. This is so if the kids specify callbacks such as
  when I start do ... end => :start, we only have them run once, and then
  run does a recursion optimization to loop forever.

  The callback functions students can generate in the module that requires DSL are:
  start/0, continouously/0, when_sensor/0, while_sensor/0, handle_message/1
  """
  defmacro init do
    quote do
      def init(_) do
        if Module.defines? __MODULE__, {:start,0}, do: start
        run()
      end
      defp run() do
        if Module.defines? __MODULE__, {:continuously,0}, do: continuously
        if Module.defines? __MODULE__, {:handle_message,1} do
          handle_message(get_msg)
        end
        run() #loop
      end
      def handle_message(_), do: :ok
    end
  end
  ## Events
  ## Variables
  def set(var_name, value), do: US.set_var(var_name, value)
  def get(var_name, value), do: US.get_var(var_name, value)
  ## Brick pi
  #set sensor type
  def bp_set_sensor_type(port_num, type_string), do: BP.set_sensor_type(port_num, type_string)
  #get sensor value
  def bp_get_sensor_value(port_num), do: BP.get_sensor_value(port_num)
  #when sensor value is <comp> <value>, do: <body>
  def when_bp_sensor_value_compare(port_num, comp_fun, value, fun) do
    is_valid = US.apply(
                (fn(x,y,z) -> comp_fun.(z,x) and not comp_fun.(z,y) end ),
                port_num,
                value
                )
    if is_valid, do: fun.()
  end
  def while_bp_sensor_value_compare(port_num, comp_fun, value, fun) do
    is_valid = US.apply(
                (fn(x,_y,z) -> comp_fun.(z,x) end ),
                port_num,
                value
                )
    if is_valid, do: fun.()
  end
  #when sensor value is <within | out of> range, do: <body>
  def when_bp_sensor_value_range(port_num, range, fun) do
    is_valid = US.apply(
                (fn(x,y,z) -> x in z and not y in z end),
                port_num,
                range
                )
    if is_valid, do: fun.()
  end
  def while_bp_sensor_value_range(port_num, range, fun) do
    is_valid = US.apply(
                (fn(x,_y,z) -> x in z end),
                port_num,
                range
                )
    if is_valid, do: fun.()
  end
  #set motor speed
  def bp_set_motor_speed(port_num, value), do: BP.set_motor_value(port_num, value)
  #get encoder value
  def bp_get_encoder_value(port_num), do: BP.get_encoder_value(port_num)
  ## Grove Pi
  ## Comms
  # send message <msg> to <unit>
  def send_message(msg, to), do: CM.send_message(msg,to)
  def get_message() do
    {msg, _sender} = US.dequeue_message
    msg
  end
  # when I receive message <msg> do: <body>
  ## Music
  # motif <motif name> do: <music program>
  # cue <motif> in <num> beats
  # (optional) cue <signal>
  # (optional) sync <signal>
end
