defmodule Blockytalky.UserState do
  use GenServer
  require Logger
  require Integer
  alias Blockytalky.BrickPi, as: BP
  alias Blockytalky.GrovePi, as: GP
  alias Blockytalky.GrovePiState, as: GPS
  alias Blockytalky.MockHW, as: MockHW
  @moduledoc """
  Keeps track of the stateful-ness of the client's BT program.
  e.g. hardware change over time, message queue to be handled
  Called by IR as needed to stash data between iterations
  state looks like:

  """
  @max_history_size 1_000
  #the state that gets passed around by this gen server e.g. %Blockytalky.UserState{}
  defstruct message_queue: [], port_values: %{},
  var_map: %{}, user_code: "", upid: nil,
  l: 0, init_funs: [], loop_funs: []
  ####
  # External API
  ## UserCode state State
  def update_state() do
    #update mock state
    if :mock in Blockytalky.RuntimeUtils.supported_hardware, do: update_mock_state()
    #update brickpi state
    if :btbrickpi in Blockytalky.RuntimeUtils.supported_hardware, do: update_bp_state()
    #update grove state
    if :btgrovepi in Blockytalky.RuntimeUtils.supported_hardware, do: update_gp_state()
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
  returns {:ok, msg} if there is one,
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
<<<<<<< HEAD
      history = GenServer.call(__MODULE__, {:get_port_value, port_id}) |> (Enum.filter(fn {_,value} -> value != nil end))
=======
    history = GenServer.call(__MODULE__, {:get_port_value, port_id}) |> (Enum.filter(fn {_,value} -> value != nil end))
>>>>>>> 4b69db249dae0a228a8e02435b37ca691d481c44
    case history do
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
  def update_var(var_name, fun) do
    #GenServer.cast(__MODULE__, {:update_var, var_name, fun})
     case get_var(var_name) do
      var -> set_var(var_name,fun.(var))
      _   -> :ok
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
  defp update_gp_state do
    port_list = GP.port_id_map
    
    |> Map.keys
    |> Enum.filter(fn port_id -> GPS.get_port_component(port_id) != nil end)
    port_values = port_list    
    |> Enum.map(fn port_id -> GP.get_component_value(port_id) end)

    Enum.zip(port_values,port_list)
    |> Enum.map(fn {v,p} -> put_value(v,p) end)

    
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
    if upid == nil, do: :timer.sleep(Application.get_env(:blockytalky, :update_rate_hibernate)), else: :timer.sleep(Application.get_env(:blockytalky, :update_rate))
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
      data_list = 
       case data_list do
         l when is_list(l) -> Enum.filter(l, (fn {_, x} -> x != nil end))
         _                 -> []
       end
      latest_value = case data_list do
        [{_,v}] -> v
        _       -> "-"
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
  # defp latest_usercode do
  #   savefiles =
  #     File.ls!(Application.get_env(:blockytalky,:user_code_dir))
  #     |> Enum.filter(filter) #only filenames that have "hostname" <> "datetime"
  #     |> Enum.sort # sort in ascending order
  #     |> Enum.reverse #reverse so most recent is head of list
  #   case savefiles do
  #     [] -> %{"code" => "", "xml" => "<xml></xml>"} #empty savefile
  #     [head | _ ] ->
  #       file = File.read!("#{Application.get_env(:blockytalky,:user_code_dir)}/#{head}")
  #       case JSX.decode(file) do
  #         {:ok, f} -> f
  #         _ -> #the  save file is corrupted
  #           #delete the file and try again
  #           File.rm! "#{Application.get_env(:blockytalky,:user_code_dir)}/#{head}"
  #           latest_usercode
  #         end
  #     _ -> %{"code" => "", "xml" => "<xml></xml>"}
  #   end
  # end
  def init(_) do
    Logger.info "Initializing #{inspect __MODULE__}"
    #restore user code if possible
    File.mkdir(Application.get_env(:blockytalky,:user_code_dir))
    filter = fn file ->
      file |>
        String.starts_with?(Blockytalky.RuntimeUtils.btu_id)
    end
    savefiles =
      File.ls!(Application.get_env(:blockytalky,:user_code_dir))
      |> Enum.filter(filter) #only filenames that have "hostname" <> "datetime"
      |> Enum.sort # sort in ascending order
      |> Enum.reverse #reverse so most recent is head of list
    uc = case savefiles do
          [] -> %{"code" => "", "xml" => "<xml></xml>"} #empty savefile
          [head | _ ] ->
            file = File.read!("#{Application.get_env(:blockytalky,:user_code_dir)}/#{head}")
            file = case JSX.decode(file) do
              {:ok, f} -> f
              _ -> %{"code" => "", "xml" => "<xml></xml>"}
                   #TODO: delete the file and try again
            end
          _ -> ""
         end
    #state = message queue, port_values, user defined var values, user_code_string, user_code pid, and loop iteration number (FRP)
    #port_values var_values are both maps of ids to lists of tuples of the form: %{id => [{iteration_number, value} ... ] ... }
    state = %Blockytalky.UserState{user_code: uc}
    {:ok, state}
  end
  def handle_call(:dequeue_message, _from, s = %Blockytalky.UserState{message_queue: []}) do
    {:reply, {:nosender, :nomsg}, s}
  end
  def handle_call(:dequeue_message, _from, s = %Blockytalky.UserState{message_queue: mq})  do
    rev_q = Enum.reverse(mq)
    [value | new_q_rev] = rev_q
    new_q = Enum.reverse(new_q_rev)
    {:reply, {:ok, value}, %Blockytalky.UserState{s | message_queue: new_q}}
  end
  def handle_call(:clear_state, _from, %Blockytalky.UserState{user_code: ucs}) do
    #we want this to be a call because we want to block progress on the caller (so that they don't try to query until this is done)
    {:reply,:ok, %Blockytalky.UserState{user_code: ucs}}
  end
  def handle_call({:get_port_value, port_id}, _from, s=%Blockytalky.UserState{port_values: port_values}) do
    value = Map.get(port_values, port_id,[])
    {:reply, value, s}
  end
  def handle_call(:get_port_value_map, _from, s=%Blockytalky.UserState{port_values: port_values}) do
    {:reply, port_values, s}
  end
  def handle_call({:get_var, var_name}, _from, s=%Blockytalky.UserState{var_map: var_map}) do
    value = Map.get(var_map, var_name,[])
    {:reply, value, s}
  end
  def handle_call(:get_user_code, _from, s=%Blockytalky.UserState{user_code: ucs}) do
    {:reply, ucs, s}
  end
  def handle_call(:get_upid, _from, s=%Blockytalky.UserState{upid: upid}) do
    {:reply, upid, s}
  end
  def handle_call(:get_loop_iteration, _from, s=%Blockytalky.UserState{l: l}) do
    {:reply, l, s}
  end
  def handle_call({:get_funs, type}, _from, s=%Blockytalky.UserState{init_funs: init_funs, loop_funs: loop_funs}) do
    funs = case type do
      :init -> init_funs
      :loop -> loop_funs
    end
    {:reply, funs, s}
  end
  def handle_call(:clear_funs, _from, s) do
    {:reply, :ok, %Blockytalky.UserState{s | init_funs: [], loop_funs: []}}
  end
  #cast
  def handle_cast({:put_value, value, port_id}, s = %Blockytalky.UserState{port_values: port_values, l: l}) do
    updated = case Map.get(port_values, port_id) do
      nil -> [{l,value}]
      list -> [{l, value} | list] |> Enum.take(@max_history_size)
    end
    #Logger.debug("user state values: #{inspect updated}")
    {:noreply, %Blockytalky.UserState{s | port_values: Map.put(port_values,port_id,updated)} }
  end
  def handle_cast({:queue_message, msg}, s=%Blockytalky.UserState{message_queue: mq}) do
    {:noreply, %Blockytalky.UserState{s | message_queue: [msg | mq]}}
  end
  def handle_cast({:set_var,var_name, value}, s=%Blockytalky.UserState{var_map: var_map, l: l}) do
    updated = case Map.get(var_map, var_name) do
      nil -> [{l,value}]
      list -> [{l, value} | list] |> Enum.take(@max_history_size)
      end
    {:noreply, %Blockytalky.UserState{s | var_map: Map.put(var_map, var_name, updated)}}
  end
  def handle_cast({:update_var, var_name, fun}, s=%Blockytalky.UserState{var_map: var_map, l: l}) do
    updated = case Map.get(var_map, var_name) do
      nil -> nil
      list ->
        [{_, head} | _ ] = list
        value = fun.(head)
        [{l, value} | list]
          |> Enum.take(@max_history_size)
      end
    {:noreply, %Blockytalky.UserState{s | var_map: Map.put(var_map, var_name, updated)}}
  end
  def handle_cast({:upload_user_code, code}, s) do
    {:noreply, %Blockytalky.UserState{s | user_code: code}}
  end
  def handle_cast({:set_upid, pid}, s) do
    {:noreply, %Blockytalky.UserState{s | upid: pid}}
  end
  def handle_cast(:inc_loop_iteration, s=%Blockytalky.UserState{l: l}) do
    {:noreply,%Blockytalky.UserState{s | l: l+1}}
  end
  def handle_cast({:push_fun, type, fun}, s=%Blockytalky.UserState{l: l, init_funs: init_funs, loop_funs: loop_funs}) do
    case type do
      :init ->
        {:noreply,%Blockytalky.UserState{s | l: l+1, init_funs: [fun | init_funs]}}
      :loop ->
        {:noreply,%Blockytalky.UserState{s | l: l+1, loop_funs: [fun | loop_funs]}}
    end
  end
  def terminate(_reason, _state) do
    Logger.info "Terminating: #{inspect __MODULE__}"
  end
end
