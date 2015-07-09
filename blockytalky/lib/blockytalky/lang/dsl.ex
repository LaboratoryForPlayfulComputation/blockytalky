defmodule Blockytalky.DSL do
  alias Blockytalky.UserState, as: US
  alias Blockytalky.BrickPi, as: BP
  alias Blockytalky.Music, as: Music
  alias Blockytalky.SonicPi, as: SP
  alias Blockytalky.CommsModule, as: CM
  #alias Blockytalky.CommsChannel, as: CC

  require Logger
  @moduledoc """
  The function-version of the Blockytalky.DSL as an intermediate representation
  (or library if you prefer)
  can be many lines to one "instruction"

  Mainly interoperates with the other APIs: Hardware, Music, Comms, and UserState
  We ``should`` do type checking / correctness checking here!
  """
  ## Macros

  defmacro __using__(_) do
    #expand when student code does `use Blockytalky.DSL`
    #register all the @attributes that will accumulate the macro function definitions
    quote do
      import Blockytalky.DSL
      require Blockytalky.DSL
      require Logger
      def init(_) do
        set(:sys_timer,[])
        GenServer.call(Blockytalky.UserState, {:get_funs,:init})
        |> Enum.map(fn x -> x.() end)
      end
      def loop() do
        #loop over timer stack global var and see if it is time to do those lambdas
        process_time_events
        dequeued_message = get_message() #get the latest message for all of the receive if blocks
        GenServer.call(Blockytalky.UserState, {:get_funs,:loop})
        |> Enum.map(fn x -> x.() end)
      end
    end
  end

  ####
  # The entry points of the user program. These get stored as asts in an @attribute (:once or :everytime)
  # and then run as lambas (anonymous callbacks) either in the init function or the loop function.
  defmacro start(do: body) do
    quote do
      GenServer.call(Blockytalky.UserCode, {:push_fun, :init, fn -> unquote(body) end})
    end
  end
  defmacro repeatedly(do: body) do
    quote do
      GenServer.call(Blockytalky.UserCode, {:push_fun, :loop, fn -> unquote(body) end})
    end
  end
  defmacro in_time(seconds, do: body) do
    quote do
      time = (:calendar.universal_time |> :calendar.datetime_to_gregorian_seconds) + round(unquote(seconds))
      push_time_event({:at_time,time, fn -> unquote(body) end})
      time = nil
    end
  end
  defmacro for_time(seconds,clauses) do
    do_body = Keyword.get(clauses, :do, nil)
    after_body = Keyword.get(clauses, :after, :ok)
    quote do
      time = (:calendar.universal_time |> :calendar.datetime_to_gregorian_seconds) + round(unquote(seconds))
      push_time_event({:until_time, time, fn -> unquote(do_body) end, fn -> unquote(after_body) end})
      time = nil
    end
  end
  @doc """
  ## Example
      iex> when_sensor "PORT_1" > 100, do: set("item",10)
  """
  defmacro when_sensor({op,_m,[port_id,value]}, do: body) do
    #need to swap varable calls for when in case the variable changes between loops,
    #but the sensor port doesn't change
    value = case value do
      {:get, meta, opts} -> {:get_var_history, meta, opts}
      _ -> value
    end
    quote do
      compare = {op, [context: Elixir, import: Kernel], [{:x, [], Elixir}, {:y, [], Elixir}]}]}]}
      GenServer.call(Blockytalky.UserCode, {:push_fun, :loop, fn ->
        when_sensor_value_compare(unquote(port_id),
          fn x,y -> unquote(compare) end,
          unquote(value), #could be a constant or a var/var history [{iteration,value}...]
          fn -> unquote(body) end
          )
        end})
    end
  end
  @doc """
  ## Example
      iex> when_sensor "PORT_1" in 1..get("my_var"), do: 1 + 1
  """
  defmacro when_sensor({:in, _m, [port_id, range={:.., _m2, [_left,_right]}]}, do: body) do
  quote do
    GenServer.call(Blockytalky.UserCode, {:push_fun, :loop, fn ->
      when_sensor_value_range(unquote(port_id),
        unquote(range), #could be a constant or a var
        fn -> unquote(body) end)
        end}
      )
    end
  end
  defmacro when_sensor({:not_in, _m, [port_id, range={:.., _m2, [_left,_right]}]}, do: body) do
    quote do
      GenServer.call(Blockytalky.UserCode, {:push_fun, :loop, fn ->
        when_sensor_value_range(unquote(port_id),
          unquote(range), #could be a constant or a var
          fn -> unquote(body) end,
          true) #not in flag
        end}
      )
    end
  end
  defmacro while_sensor({op,[context: context | _ ],[port_id,value]}, do: body)do
    compare = {op, [context: Elixir, import: Kernel], [{:x, [], Elixir}, {:y, [], Elixir}]}]}]}
    quote do
      GenServer.call(Blockytalky.UserCode, {:push_fun, :loop, fn ->
        while_sensor_value_compare(unquote(port_id),
          fn x,y -> unquote(compare) end,
          unquote(value), #could be a constant or a var
          fn -> unquote(body) end
          )
        end}
      )
    end
  end
  defmacro while_sensor({:in, _m, [port_id, range={:.., _m2, [_left,_right]}]}, do: body) do
    quote do
      GenServer.call(Blockytalky.UserCode, {:push_fun, :loop, fn ->
        while_sensor_value_range(unquote(port_id),
          unquote(range), #could be a constant or a var
          fn -> unquote(body) end)
          end}
        )
      end
  end
  defmacro while_sensor({:not_in, _m, [port_id, range={:.., _m2, [_left,_right]}]}, do: body) do
    quote do
      GenServer.call(Blockytalky.UserCode, {:push_fun, :loop, fn ->
        while_sensor_value_range(unquote(port_id),
          unquote(range), #could be a constant or a var
          fn -> unquote(body) end,
          true) #not in flag
        end}
      )
    end
  end
  defmacro when_receive(msg, do: body) do
    #msg could be get("var")
    quote do
      GenServer.call(Blockytalky.UserCode, {:push_fun, :loop, fn ->
        if(unquote(msg) == dequeued_message) do #dequeue message is set at the beginning of the loop
          unquote(body)
        end
      end})
    end
  end
  ## Events
  ## Variables
  def set(var_name, value), do: US.set_var(var_name, value)
  def get(var_name) do
    case US.get_var(var_name) do #runtime error message
    nil ->
      Blockytalky.Endpoint.broadcast! "uc:command", "error", %{body: "#{var_name} has not been set!"}
      nil
    v -> v
    end
  end
  @doc """
  [{iteration, var_value}, ...]
  """
  def get_var_history(var_name) do
    case US.get_var_history(var_name) do #runtime error message
      nil ->
        Blockytalky.Endpoint.broadcast! "uc:command", "error", %{"body" => "#{var_name} has not been set!"}
        nil
      v -> v
    end
 end
  ## HW

  #get sensor value
  def get_sensor_value(port_num) do
     US.get_value(port_num)
  end

  ####
  # Helper functions called by macros
  # timer Events
  def process_time_events() do
    stack = get_sys_timer
      |> Enum.filter(fn x -> do_timer_action(x) end)
    set(:sys_timer, stack)
  end
  def push_time_event(event) do
    stack = get_sys_timer
    new_stack  = [event | stack]
    set(:sys_timer, new_stack)
  end
  defp get_sys_timer do
    case get(:sys_timer) do
      nil -> []
      v -> v
    end
  end
  @doc """
  In both of the following cases, if they return false, pop off of the stack
  """
  def do_timer_action({:at_time, time, fun}) do
    now = :calendar.universal_time |> :calendar.datetime_to_gregorian_seconds
    if now > time do
      fun.()
      false
    else
      true
    end
  end
  def do_timer_action({:until_time, time, do_fun}) do
    now = :calendar.universal_time |> :calendar.datetime_to_gregorian_seconds
    if now < time do
      do_fun.()
      true
    else
      false
    end

  end
  def do_timer_action({:until_time, time, do_fun, then_fun}) do
    now = :calendar.universal_time |> :calendar.datetime_to_gregorian_seconds
    if now < time do
      do_fun.()
      true
    else
      then_fun.()
      false
    end

  end
  #when sensor value is <comp> <value>, do: <body>
  def when_sensor_value_compare(port_id, comp_fun, value, body_fun) do
    #this is confusing, refactor this to be less awful.
    #Purpose: compare the change in the sensor value to a variable or constant, and if true, apply some body function
    #handles the edge case that the sensor stayed the same, but the value being compared against changed thus making the "when" trigger.
    {apply_fun, value} = case value do
      [{i, latest_value},{j, previous_value} | _ ] ->
        {fn(x,y,z) -> x != nil and comp_fun.(x,z) and (not comp_fun.(y,z) or not comp_fun.(y,previous_value)) end, latest_value}
      [{_, only_value}] ->
        {fn(x,y,z) -> x != nil and comp_fun.(x,z) and not comp_fun.(y,z) end, only_value}
      v ->
        {fn(x,y,z) -> x != nil and comp_fun.(x,z) and not comp_fun.(y,z) end, v}
    end
    is_valid = US.apply(
                apply_fun,
                port_id,
                value
                )
    if is_valid, do: body_fun.()
  end
  def while_sensor_value_compare(port_num, comp_fun, value, fun) do
    is_valid = US.apply(
                (fn(x,_y,z) -> x != nil and comp_fun.(x,z) end ),
                port_num,
                value
                )
    if is_valid, do: fun.()
  end
  #when sensor value is <within | out of> range, do: <body>
  def when_sensor_value_range(port_num, range, fun, not_in \\ false) do
    check_function = if not_in do
       fn(x,y,z) -> x != nil and not x in z and  y in z end
     else
       fn(x,y,z) -> x != nil and x in z and not y in z end
     end
    is_valid = US.apply(
                check_function,
                port_num,
                range
                )
    if is_valid, do: fun.()
  end
  def while_sensor_value_range(port_num, range, fun, not_in \\ false) do
    check_function = if not_in do
       fn(x,_y,z) -> x != nil and not x in z end
     else
       fn(x,_y,z) -> x != nil and x in z end
     end
    is_valid = US.apply(
                (fn(x,_y,z) -> x != nil and x in z end),
                port_num,
                range
                )
    if is_valid, do: fun.()
  end
  #set motor speed
  def bp_set_motor_speed(port_num, value) do
    if value in -100..100 do
      BP.set_motor_value(port_num, value)
    else
      Blockytalky.Endpoint.broadcast "uc:command", "error", %{"body" => "Tried to set motor speed to value not in -100 to 100: #{inspect value}"}
    end
  end
  ## Grove Pi
  ## Comms
  # message <msg> to <unit>
  def send_message(msg, to), do: CM.send_message(msg,to)
  def get_message() do
    {_sender, msg} = US.dequeue_message
    msg
  end
  def say(msg) do
    Blockytalky.Endpoint.broadcast "comms:message", "say", %{"body" => msg}
  end
  ## Music
  # motif <motif name> do: <music program>
  # cue <motif> in <num> beats
  # (optional) cue <signal>
  # (optional) sync <signal>
end
