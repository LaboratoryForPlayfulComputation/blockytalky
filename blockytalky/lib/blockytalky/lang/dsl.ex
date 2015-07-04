defmodule Blockytalky.DSL do
  alias Blockytalky.UserState, as: US
  alias Blockytalky.BrickPi, as: BP
  alias Blockytalky.Music, as: Music
  alias Blockytalky.SonicPi, as: SP
  alias Blockytalky.CommsModule, as: CM
  alias Blockytalky.CommsChannel, as: CC
  @moduledoc """
  The function-version of the Blockytalky.DSL as an intermediate representation
  (or library if you prefer)
  can be many lines to one "instruction"

  Mainly interoperates with the other APIs: Hardware, Music, Comms, and UserState
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

  defmacro __before_compile__(env) do
    start_funs = case Module.get_attribute(env.module, :start) do
      nil -> []
      x -> x |> Enum.map(fn x -> {:fn, [], [{:->, [], [[], x]}]} end)
    end
    con_funs = case Module.get_attribute(env.module, :continouously) do
      nil -> []
      x -> x |> Enum.map(fn x -> {:fn, [], [{:->, [], [[], x]}]} end)
    end
    when_sensor_funs = case Module.get_attribute(env.module, :when_sensor) do
      nil -> []
      x -> x |> Enum.map(fn x -> {:fn, [], [{:->, [], [[], x]}]} end)
    end

    quote do
      def init(_) do
        unquote(start_funs) |> Enum.map(fn(x) -> x.() end)
      end
      def loop() do
        unquote(con_funs) |> Enum.map(fn(x) -> x.() end)
        unquote(when_sensor_funs) |> Enum.map(fn(x) -> x.() end)
      end
    end
  end

  defmacro __using__(_) do
    quote do
      import Blockytalky.DSL
      require Blockytalky.DSL
      @before_compile Blockytalky.DSL
      Module.register_attribute(__MODULE__, :when_sensor, accumulate: true)
      Module.register_attribute(__MODULE__, :while_sensor, accumulate: true)
      Module.register_attribute(__MODULE__, :receive_message, accumulate: true)
      Module.register_attribute(__MODULE__, :start, accumulate: true)
      Module.register_attribute(__MODULE__, :continuously, accumulate: true)
    end
  end

  defmacro when_sensor({op,m,[port_id,value]}, do: body) do
    value = case value do
      {:get, meta, opts} -> {:get_var_history, meta, opts}
      _ -> false
    end
    ast = quote do
      when_bp_sensor_value_compare(unquote(port_id),
        fn x,y -> unquote({op,[content: Elixir, import: Kernel],[:x,:y]}) end,
        unquote(value), #could be a constant or a var
        fn -> unquote(body) end
        )
    end
    #return:
    quote bind_quoted: [ast: ast] do
      Module.put_attribute __MODULE__, :when_sensor, ast
    end
  end
  defmacro while_sensor do
    quote do

    end
  end
  defmacro start(do: body) do
    quote bind_quoted: [ body: body ]
    do
      Module.put_attribute __MODULE__, :start, body
    end
  end
  defmacro continuously(do: body) do
    quote bind_quoted: [ body: body ]
      do
      Module.put_attribute __MODULE__, :continouously, body
    end
  end
  ## Events
  ## Variables
  def set(var_name, value), do: US.set_var(var_name, value)
  def get(var_name), do: US.get_var(var_name)
  def get_var_history(var_name), do: get_var_history(var_name)
  ## Brick pi
  #set sensor type
  def bp_set_sensor_type(port_num, type_string), do: BP.set_sensor_type(port_num, type_string)
  #get sensor value
  def bp_get_sensor_value(port_num) do
     US.get_value(port_num)
  end
  #when sensor value is <comp> <value>, do: <body>
  def when_bp_sensor_value_compare(port_id, comp_fun, value, body_fun) do
    #this is confusing, refactor this to be less awful.
    #Purpose: compare the change in the sensor value to a variable or constant, and if true, apply some body function
    {apply_fun, value} = case value do
      [{i, latest_value},{j, previous_value}] when j == (i-1) -> {fn(x,y,z) -> comp_fun.(x,z) and (not comp_fun.(y,z) or not comp_fun.(y,previous_value)) end, latest_value}
      v -> {fn(x,y,z) -> comp_fun.(x,z) and not comp_fun.(y,z) end, v}
    end
    is_valid = US.apply(
                (fn(x,y,z) -> comp_fun.(x,z) and not comp_fun.(y,z) end ),
                port_id,
                value
                )
    if is_valid, do: body_fun.()
  end
  def while_bp_sensor_value_compare(port_num, comp_fun, value, fun) do
    is_valid = US.apply(
                (fn(x,_y,z) -> comp_fun.(x,z) end ),
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
