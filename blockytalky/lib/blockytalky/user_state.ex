defmodule Blockytalky.UserState do
  use GenServer
  require Logger
  alias Blockytalky.BrickPi, as: BP
  @moduledoc """
  Keeps track of the statful-ness of the client's BT program.
  e.g. hardware change over time, message queue to be handled
  Called by IR as needed to stash data between iterations
  state looks like:
  {[message queue], %{port_id => {new_value, old_value}}, %{var_name => value}}
  """
  @file_dir "#{Application.get_env(:blockytalky, Blockytalky.Endpoint, __DIR__)[:root]}/usercode"
  @btu_id Application.get_env(:blockytalky, :id, "Unknown")
  @supported_hardware Application.get_env(:blockytalky, :supported_hardware)
  ####
  # External API
  ## UserCode state State
  def update_state() do
    #update brickpi state
    if :btbrickpi in @supported_hardware, do: update_bp_state()
    #update grove state
    #update music state
    #update messaging state
  end
  def upload_user_code(code_string) do
    GenServer.call(__MODULE__, {:upload_user_code, code_string})
    #backup usercode
    {{y,mo,d},{h,mi,s}} = :calendar.universal_time
    file_name = Enum.join([@btu_id,y,mo,d,h,mi,s], "_") <> ".ex"
    File.write("#{@file_dir}/#{file_name}", code_string)
  end
  def execute_user_code() do
    code_string = GenServer.call(__MODULE__, :get_user_code)
    Code.compile_string(code_string)
    loop_stream = Stream.repeatedly (fn ->
      UserCode.loop()
      receive do
        _ -> :ok #only :updated for now
      end
    end)
    uc_pid = spawn (fn ->
      UserCode.init()
      for _ <- loop_stream, do: :ok
    end)
    GenServer.cast(__MODULE__, {:set_upid, uc_pid})
  end
  def stop_user_code() do
    upid = GenServer.call(__MODULE__, :get_upid)
    if upid, do: Process.exit(upid, :kill)
    GenServer.cast(__MODULE__, :clear_state)
  end
  def queue_message(msg) do
    GenServer.cast(__MODULE__, {:queue_message, msg})
  end
  @doc """
  returns {:ok, msg} if there is one,
  returns {:nomsg,:nomsg} if the queue is empty
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
  def get_value(value, port_id) do
    GenServer.call(__MODULE__, {:get_value, port_id})
  end
  @doc """
  applies the passed function with airity 3 to new value, and old value of
  the port with the passed id.
  ((x,y,z) -> any), #) -> any
  ## Example
      iex> Blockytalky.UserScript.apply(fn(x,y,z) -> x > z and x < y end, 1, 10)
  """
  def apply(fun, port_id, value) do
    {new_value, old_value} = GenServer.call(__MODULE__,{:get_value,port_id})
    fun.(new_value, old_value, value)
  end

  def set_var(var_name, var_value), do: GenServer.cast(__MODULE__,{:set_var,var_name, var_value})
  def get_var(var_name), do: GenServer.call(__MODULE__, {:get_var,var_name})
  ####
  # Internal API
  defp update_bp_state do
    sensor_ports = ~w/PORT_1 PORT_2 PORT_3 PORT_4/
    motor_ports = ~w/PORT_A PORT_B PORT_C PORT_D/
    for x <- sensor_ports do
      put_value(x,BP.get_sensor_value(x))
    end
    for x <- motor_ports do
      put_value(x, BP.get_encoder_value(x))
    end
  end
  def loop() do
    :timer.sleep(1_000)
    update_state()
    upid = GenServer.call(__MODULE__, :get_upid)
    if upid do
      send upid, :updated
    end
    loop()
  end
  ####
  # Genserver Implementation
  # Ch. 16 Programming Elixir

  def start_link() do
    status = GenServer.start_link(__MODULE__,[], name: __MODULE__)
    spawn loop()
    status
  end

  def init(_) do
    Logger.info "Starting #{inspect __MODULE__}"
    #restore user code if possible
    uc = case File.ls!(@file_dir) |> Enum.sort do
          [] -> ""
          [head | _] -> File.read("#{@file_dir}/#{head}")
          _ -> ""
         end
    #state = message queue, port_values, user defined var values, user_code_string, and user_code pid
    state = {[],%{},%{},uc,nil}
    {:ok, state}
  end
  def handle_call(:dequeue_message, _from, {mq, port_values, var_map, ucs, upid}) when length(mq) > 0  do
    rev_q = Enum.reverse(mq)
    [value | new_q_rev] = rev_q
    new_q = Enum.reverse(new_q_rev)
    {:reply, {:ok, value}, {new_q,port_values, var_map, ucs, upid}}
  end
  def handle_call(:dequeue_message, _from, s)  do
    {:reply, {:nomsg, :nomsg}, s}
  end
  def handle_call({:get_value, port_id}, _from, s={_mq, port_values, _var_map, _ucs, _upid}) do
    value = Map.get(port_values, port_id, {:noval, :noval})
    {:reply, value, s}
  end
  def handle_call({:get_var, var_name}, _from, s={_mq, _port_values, var_map, _ucs, _upid}) do
    value = Map.get(var_map, var_name)
    {:reply, value, s}
  end
  def handle_call(:get_user_code, _from, s={_mq, _port_values, _var_map, ucs, _upid}) do
    {:reply, ucs, s}
  end
  def handle_call(:get_upid, _from, s={_mq, _port_values, _var_map, _ucs, upid}) do
    {:reply, upid, s}
  end
  #cast
  def handle_cast({:put_value, value, port_id}, {mq,port_values, var_map, ucs, upid}) do
    fetched_value = Map.get(port_values,port_id,{:noval,:noval})
    updated = case fetched_value do
      {:noval, :noval} ->
        {value, value}
      {new_value, old_value} ->
        {value, new_value}
    end

    {:noreply, { mq , Map.put(port_values,port_id,updated), var_map, ucs, upid } }
  end
  def handle_cast({:queue_message, msg}, {mq, port_values, var_map, ucs, upid}) do
    {:noreply, {[msg | mq], port_values, var_map, ucs, upid}}
  end
  def handle_cast({:set_var,var_name, value}, {mq, port_values, var_map, ucs, upid}) do
    var_map = Map.put(var_map, var_name, value)
    {:noreply, {mq, port_values, var_map, ucs, upid}}
  end
  def handle_cast({:upload_code, code_string},{mq, port_values, var_map, ucs, upid}) do
    {:noreply, {{mq, port_values, var_map, code_string, upid}}}
  end
  def handle_cast({:set_upid, pid}, {mq, port_values, var_map, ucs, upid}) do
    {:noreply, {mq, port_values, var_map, ucs, pid}}
  end
  def handle_cast(:clear_state,{_mq, _port_values, _var_map, ucs, _upid}) do
    {:noreply, {[],%{},%{}, ucs, nil}}
  end
  def terminate(_reason, _state) do
    Logger.info "Terminating: #{inspect __MODULE__}"
  end

end
