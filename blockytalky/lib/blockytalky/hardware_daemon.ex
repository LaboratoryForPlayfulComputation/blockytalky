defmodule Blockytalky.HardwareDaemon do
  use Supervisor
  alias Blockytalky.PythonQuerier, as: PythonQuerier
  require Logger

  @moduledoc """
  The supervisor and api for all hardware (sensor / motor) hats that can
  be interfaced with.
  Calls to the -hardware_command- interface make the appropriate python api call
  to query the hardware.

  If you are adding a new python hardware api, please implement a setup function
  Then please add the module name to the environment it is able to be run from
  """

  ####
  #config
  @script_dir "#{Application.get_env(:blockytalky, Blockytalky.Endpoint, __DIR__)[:root]}/lib/hw_apis"
  @supported_hardware Application.get_env(:blockytalky, :supported_hardware)

  ####
  # External API
  def get_sensor_value(:btbrickpi,port_num) do
    value = PythonQuerier.run_result(:btbrickpi, :get_sensor_value,[port_num])
    type = PythonQuerier.run_result(:btbrickpi, :get_sensor_type,[port_num])
    #normalize from brickpi to blockytalky values here:
    case type do
      _ -> value
    end
  end
  def get_sensor_value(:mock, port_num), do: PythonQuerier.run_result(:mock, :get_sensor_value,[port_num])
  def get_encoder_value(:btbrickpi,port_num), do: PythonQuerier.run_result(:btbrickpi, :get_encoder_value,[port_num])
  def set_sensor_type(:btbrickpi,port_num, sensor_type), do: PythonQuerier.run(:btbrickpi, :set_sensor_type, [port_num, sensor_type])
  def set_sensor_type(:mock, port_num, value), do: PythonQuerier.run(:mock, :set_sensor_type, [port_num, value])
  def set_motor_value(:btbrickpi, port_num, value)do
    new_value = normalize(value, [low: -100, high: 100], [low: -255, high: 255])
    PythonQuerier.run(:btbrickpi, :set_motor_value,[port_num, new_value])
  end

  ####
  #Helper functions

  #  converts the value in some range to the same percentile in the new range
  #  assumes values are integers (uses integer division)
  #  type: int * [low: int, high: int] * [low: int, high: int] -> int
  defp normalize(value, from, to)  do
    (value - from[:low])
    |> (&(&1 * (to[:high] - to[:low]))).()
    |> (&(div(&1,(from[:high] - from[:low])))).()
    |> (&(&1 + to[:low])).()
  end
  ####
  #Supervisor implementation
  # See: Ch. 17 of Programming Elixir
  def start_link() do
    {:ok, _pid} = Supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    #create python instances
    Logger.debug "creating python instance at the #{inspect @script_dir} directory"
    #create hw child process instances and spin them up
    hw_children = Enum.map @supported_hardware, fn hw ->
      worker(PythonQuerier, [hw], id: hw) end
    Logger.debug "Starting HW Workers: #{inspect hw_children}"
    supervise hw_children, strategy: :one_for_one
  end
end

defmodule Blockytalky.PythonQuerier do
  use GenServer

  require Logger
  @script_dir "#{Application.get_env(:blockytalky, Blockytalky.Endpoint, __DIR__)[:root]}/lib/hw_apis"
  @supported_hardware Application.get_env(:blockytalky, :supported_hardware)
  @moduledoc """
  This is a Gen Server implementation that's job is to run the python scripts
  for interfacing with the BTU hardware (brick pi, grove pi, etc).
  continuously read values get put it into a stream for
  consumption by the userscript.

  The state our Genserver will keep track of is a tuple:
  {python_env, pythong_module}

  we can query the GenServer in order to run the script with those args.
  Name keyword can be any of: #{inspect Application.get_env(:blockytalky, :supported_hardware)}
  """

  ####
  #External API - should only be called by HardwareDaemon
  def start_link(python_module) do
    {:ok, python_env} = :python.start([{:python_path,String.to_char_list(@script_dir)}])
    Logger.debug "PythonQuerier: Started with module: #{inspect python_module}"
    status = {:ok, _pid} = GenServer.start_link(__MODULE__, {python_env, python_module,[]}, name: python_module)
    #run setup on init.
    Logger.debug "Running setup for: #{inspect python_module}"
    run(python_module, :setup, [])
    status
  end
  @doc """
  nice wrapper for casting :run on the genserver.
  """
  def run(name,method,args) when name in @supported_hardware, do: GenServer.cast(name, {:run, method, args})
  def run(name,_,_), do: _run_error(name)
  @doc """
  nice wrapper for calling :run on the genserver.
  """
  def run_result(name,method, args) when name in @supported_hardware, do: GenServer.call( name, {:run, method, args})
  def run_result(name,_,_), do: _run_error(name)
  defp _run_error(name), do: {:error, "Hardware: #{inspect name} is not supported in this environment. Please use supported hardware: #{inspect @supported_hardware}"}
  ####
  #GenServer implementation
  # See: Ch16 of Programming Elixir

  def init(python_env, python_module, port_list) do
    #return state
    {:ok, {python_env, python_module, port_list}}
  end

  @doc """
  For when we care about the result, such as reading sensor / motor values
  """
  def handle_call({:run,:get_sensor_type, [port_num]}, state={_python_env, _python_module, port_type_list}) do
    type = Keyword.get(port_type_list, :"#{port_num}",0) #default to 0 (not set) if we cannot find it in the list.
    {:reply, {:ok, type}, state}
  end
  def handle_call({:run, method, args}, _from, state={python_env, python_module,_port_type_list}) do
    #erlport run the script
    Logger.debug "About to run #{inspect python_module}.#{inspect method}(#{inspect args})"
    result = :python.call(python_env, python_module, method, args)
    Logger.debug "Result: #{inspect result}"
    #return result and keep state unchanged
    {:reply, {:ok, result}, state}
  end

  @doc """
  for fire-and-forget scripts (like set motor port whatever to whatever) we clean
  just make casts.
  """
  def handle_cast({:run, method=:set_sensor_type, args=[port_num, type]},_state={python_env, python_module, port_type_list}) do
    #runscript
    :python.call(python_env, python_module, method, args)
    #add or update port_type
    {:noreply,{python_env, python_module, Keyword.put(port_type_list, :"#{port_num}", type)}}
  end
  def handle_cast({:run, method, args},state={python_env, python_module, _port_type_list}) do
    #runscript
    :python.call(python_env, python_module, method, args)
    {:noreply,state}
  end
  def terminate(_reason, {python_env, python_module, _port_type_list}) do
    #clean up env
    Logger.info "Terminating: #{inspect python_module}. UI should repoll for port types / reset port types after restart."
    :python.stop(python_env)
  end
end
