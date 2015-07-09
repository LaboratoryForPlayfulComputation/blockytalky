defmodule Blockytalky.UserState do
  use GenServer
  require Logger
  require Integer
  alias Blockytalky.BrickPi, as: BP
  alias Blockytalky.MockHW, as: MockHW
  @moduledoc """
  Keeps track of the statful-ness of the client's BT program.
  e.g. hardware change over time, message queue to be handled
  Called by IR as needed to stash data between iterations
  state looks like:

  """
  @file_dir "#{Application.get_env(:blockytalky, Blockytalky.Endpoint, __DIR__)[:root]}/usercode"
  @supported_hardware Application.get_env(:blockytalky, :supported_hardware)
  @update_rate Application.get_env(:blockytalky, :update_rate)
  @update_rate_hibernate Application.get_env(:blockytalky, :update_rate_hibernate)
  @max_history_size 1_000
  ####
  # External API
  ## UserCode state State
  def update_state() do
    #update mock state
    if :mock in @supported_hardware, do: update_mock_state()
    #update brickpi state
    if :btbrickpi in @supported_hardware, do: update_bp_state()
    #update grove state
    #update music state
    #update messaging state
  end
  def upload_user_code(code_map) do
    GenServer.cast(__MODULE__, {:upload_user_code, code_map})
  end

  def execute_user_code() do
    stop_user_code(false) #stop currently running code before rerunning
    code_map = GenServer.call(__MODULE__, :get_user_code)
    GenServer.call(__MODULE__, :clear_funs)
    GenServer.call(__MODULE__, :clear_state)
    try do
      code_string = code_map |> Map.get("code")
      Code.compile_string(code_string)
      if(code_string != "") do
        loop_stream = Stream.repeatedly (fn ->
          Blockytalky.UserCode.loop() # do one iteration of the loop
          receive do #wait for values to be updated to run again (FRP-like)
            _ -> :ok #only :updated for now
          end
        end)
        uc_pid = spawn (fn ->
          Blockytalky.Endpoint.broadcast("uc:command", "progress", %{body: "Program Running!"})
          Blockytalky.UserCode.init(:ok) #call init once, this is code such as "when I start"
          for _ <- loop_stream, do: :ok
        end)
        Logger.debug "running program: #{inspect uc_pid}"
        GenServer.cast(__MODULE__, {:set_upid, uc_pid})
      else
        Blockytalky.Endpoint.broadcast("uc:command", "error", %{body: "No program to run!"})
      end
    rescue
      e ->
        Logger.debug "Error compiling user code: #{inspect e}"
        Blockytalky.Endpoint.broadcast("uc:command", "error", %{body: "Failed to compile program"}) #user should never see this, but for now it is a nicity
    end
  end
  def stop_user_code(verbose \\ true) do
    upid = GenServer.call(__MODULE__, :get_upid)
    if upid do
      Process.exit(upid, :kill)
      if verbose, do: Blockytalky.Endpoint.broadcast("uc:command", "progress", %{body: "Program Stopped!"})
    else
      if verbose, do: Blockytalky.Endpoint.broadcast("uc:command", "progress", %{body: "No code running."})
    end
    GenServer.call(__MODULE__, :clear_state)
  end
  def queue_message(msg) do
    GenServer.cast(__MODULE__, {:queue_message, msg})
  end
  @doc """
  returns {sender, msg} if there is one,
  returns {:nosender,:nomsg} if the queue is empty
  """
  def dequeue_message do
    GenServer.call(__MODULE__, :dequeue_message)
  end
  @doc """
  updates the state with the new value for that port,
  setting the old value to the previous new value if there was one
  or both to the new value if there wasn't a previous value
  """
  def put_value(value, port_id) do
    GenServer.cast(__MODULE__,{:put_value, value, port_id})
  end
  def get_value(port_id) do
    case GenServer.call(__MODULE__, {:get_port_value, port_id}) do
      [{_, value} | _ ] -> value
      _ -> nil
    end
  end
  @doc """
  applies the passed function with airity 3 to new value, and old value of
  the port with the passed id.
  ((x,y,z) -> any), port_id, value_for_z) -> any
  where x is the newest value of that port and y is the previous value
  useful for seeing if a user defined value is within/outside of a range
  ## Example
      iex> Blockytalky.UserScript.apply(fn(x,y,z) -> x > z and x < y end, 1, 10)
  """
  def apply(fun, port_id, value) do
    {new_value, old_value } = case GenServer.call(__MODULE__,{:get_port_value,port_id}) do
      [{_current, nv}, {_prev, ov} | _tail] -> {nv, ov}
      [{_current, nv} | _] -> {nv, nil}
      _ -> {nil, nil}
    end
    fun.(new_value, old_value, value)
  end

  def set_var(var_name, var_value), do: GenServer.cast(__MODULE__,{:set_var,var_name, var_value})
  def get_var(var_name) do
     case GenServer.call(__MODULE__, {:get_var,var_name}) do
       [{_, value} | _ ] -> value
       _ -> nil
     end
   end
  def get_var_history(var_name) do
    GenServer.call(__MODULE__, {:get_var,var_name})
  end
  ####
  # Internal API
  defp update_bp_state do
    sensor_ports = ~w/PORT_1 PORT_2 PORT_3 PORT_4/
    motor_ports = ~w/PORT_A PORT_B PORT_C PORT_D/
    _ = for x <- sensor_ports do
      case BP.get_sensor_value(x) do
        :undefined -> :ok # if no value, drop it for now
        v -> put_value(v,x) #value, port
      end
    end
    _ = for x <- motor_ports do
      case BP.get_encoder_value(x) do
        :undefined -> :ok # if no value returned from python, drop it for now
        nil -> :ok #same with values dropped purposefully
        v -> put_value(v,x)#value, port
      end
    end
  end
  defp update_mock_state do
    sensor_ports = for {key,_} <- MockHW.port_map, do: key
    for x <- sensor_ports do
      value = MockHW.get_sensor_value(x)
      #Logger.debug "Mock_hardware update: #{inspect value}"
      put_value(value, x)
    end
  end
  def loop() do
    upid = GenServer.call(__MODULE__, :get_upid)
    if upid == nil, do: :timer.sleep(@update_rate_hibernate), else: :timer.sleep(@update_rate)
    update_state()
    if upid do
      send upid, :updated
    end
    if Integer.is_even(GenServer.call(__MODULE__, :get_loop_iteration)) do
      push_to_clients()
    end
    GenServer.cast(__MODULE__, :inc_loop_iteration)
    loop()
  end
  defp push_to_clients do
    #push to clients
    #broadcase sensor / motor values
    values_json = GenServer.call(__MODULE__,:get_port_value_map) |> strip_oks
    #Logger.debug("#{inspect values_json}")
    Blockytalky.Endpoint.broadcast "hardware:values", "all",  %{body: values_json}
  end
  defp strip_oks(map) do
    list = for {key,data_list} <- map do
      latest_value = case data_list do
        [{_iteration, nil} | _ ] -> "-"
        [{_iteration, v} | _ ] -> v #get the latest value
        _ -> "-"
      end
      {key, latest_value}
    end
    Enum.into(list, %{})
  end
  ####
  # Genserver Implementation
  # Ch. 16 Programming Elixir

  def start_link() do
    status = GenServer.start_link(__MODULE__,[], name: __MODULE__)
    spawn (fn -> loop() end)
    status
  end

  def init(_) do
    Logger.info "Starting #{inspect __MODULE__}"
    #restore user code if possible
    File.mkdir(@file_dir)
    uc = case File.ls!(@file_dir)  |> Enum.sort |> Enum.reverse do
          [] -> %{"code" => "", "xml" => "<xml></xml>"}
          [head | _] ->
            file = File.read!("#{@file_dir}/#{head}")
            file = JSX.decode!(file)
          _ -> ""
         end
    #state = message queue, port_values, user defined var values, user_code_string, user_code pid, and loop iteration number (FRP)
    #port_values var_values are both maps of ids to lists of tuples of the form: %{id => [{iteration_number, value} ... ] ... }
    state = {[],%{},%{},uc,nil,0,[],[]}
    {:ok, state}
  end
  def handle_call(:dequeue_message, _from, {[], port_values, var_map, ucs, upid,l, init_funs, loop_funs})  do
    {:reply, {:nosender, :nomsg}, {[], port_values, var_map, ucs, upid,l, init_funs, loop_funs}}
  end
  def handle_call(:dequeue_message, _from, {mq, port_values, var_map, ucs, upid,l, init_funs, loop_funs})  do
    rev_q = Enum.reverse(mq)
    [value | new_q_rev] = rev_q
    new_q = Enum.reverse(new_q_rev)
    {:reply, {:ok, value}, {new_q,port_values, var_map, ucs, upid,l, init_funs, loop_funs}}
  end
  def handle_call(:clear_state, _from, {_mq, _port_values, _var_map, ucs, _upid, l, init_funs, loop_funs}) do
    #we want this to be a call because we want to block progress on the caller (so that they don't try to query until this is done)
    {:reply,:ok, {[],%{},%{}, ucs, nil, 0,init_funs, loop_funs}}
  end
  def handle_call({:get_port_value, port_id}, _from, s={_mq, port_values, _var_map, _ucs, _upid,_l, _init_funs, _loop_funs}) do
    value = Map.get(port_values, port_id)
    {:reply, value, s}
  end
  def handle_call(:get_port_value_map, _from, s={_mq, port_values, _var_map, _ucs, _upid,_l, _init_funs, _loop_funs}) do
    {:reply, port_values, s}
  end
  def handle_call({:get_var, var_name}, _from, s={_mq, _port_values, var_map, _ucs, _upid,_l, _init_funs, _loop_funs}) do
    value = Map.get(var_map, var_name)
    {:reply, value, s}
  end
  def handle_call(:get_user_code, _from, s={_mq, _port_values, _var_map, ucs, _upid,_l, _init_funs, _loop_funs}) do
    {:reply, ucs, s}
  end
  def handle_call(:get_upid, _from, s={_mq, _port_values, _var_map, _ucs, upid,_l, _init_funs, _loop_funs}) do
    {:reply, upid, s}
  end
  def handle_call(:get_loop_iteration, _from, s={_,_,_,_,_,l,_,_}) do
    {:reply, l, s}
  end
  def handle_call({:get_funs, type}, _from, s={_,_,_,_,_,_,init_funs, loop_funs}) do
    funs = case type do
      :init -> init_funs
      :loop -> loop_funs
    end
    {:reply, funs, s}
  end
  def handle_call(:clear_funs, _from, {mq, port_values, var_map, ucs, upid, l, _init, _loop}) do
    {:reply, :ok, {mq, port_values, var_map, ucs, upid, l, [],[]}}
  end
  #cast
  def handle_cast({:put_value, value, port_id}, {mq,port_values, var_map, ucs, upid,l, init_funs, loop_funs}) do
    updated = case Map.get(port_values, port_id) do
      nil -> [{l,value}]
      list -> [{l, value} | list] |> Enum.take(@max_history_size)
    end
    #Logger.debug("user state values: #{inspect updated}")
    {:noreply, { mq , Map.put(port_values,port_id,updated), var_map, ucs, upid, l, init_funs, loop_funs } }
  end
  def handle_cast({:queue_message, msg}, {mq, port_values, var_map, ucs, upid, l, init_funs, loop_funs}) do
    {:noreply, {[msg | mq], port_values, var_map, ucs, upid, l, init_funs, loop_funs}}
  end
  def handle_cast({:set_var,var_name, value}, {mq, port_values, var_map, ucs, upid, l, init_funs, loop_funs}) do
    updated = case Map.get(var_map, var_name) do
      nil -> [{l,value}]
      list -> [{l, value} | list] |> Enum.take(@max_history_size)
      end
    {:noreply, {mq, port_values, Map.put(var_map, var_name, updated), ucs, upid, l, init_funs, loop_funs}}
  end
  def handle_cast({:upload_user_code, code_map}, {mq, port_values, var_map, _ucs, upid, l, init_funs, loop_funs}) do
    {:noreply, {mq, port_values, var_map, code_map, upid, l, init_funs, loop_funs}}
  end
  def handle_cast({:set_upid, pid}, {mq, port_values, var_map, ucs, _upid, l, init_funs, loop_funs}) do
    {:noreply, {mq, port_values, var_map, ucs, pid, l, init_funs, loop_funs}}
  end
  def handle_cast(:inc_loop_iteration, {mq,pv,vm,ucs,upid,l, init_funs, loop_funs}) do
    {:noreply,{mq,pv,vm,ucs,upid,(l+1), init_funs, loop_funs}}
  end
  def handle_cast({:push_fun, type, fun}, {mq,pv,vm,ucs,upid,l, init_funs, loop_funs}) do
    case type do
      :init ->
        {:noreply,{mq,pv,vm,ucs,upid,(l+1), [fun | init_funs], loop_funs}}
      :loop ->
        {:noreply,{mq,pv,vm,ucs,upid,(l+1), init_funs, [fun | loop_funs]}}
    end
  end
  def terminate(_reason, _state) do
    Logger.info "Terminating: #{inspect __MODULE__}"
  end
end
