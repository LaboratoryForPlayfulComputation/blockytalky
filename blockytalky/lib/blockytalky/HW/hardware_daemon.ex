defmodule Blockytalky.HardwareDaemon do
  use Supervisor
  alias Blockytalky.PythonQuerier, as: PythonQuerier
  require Logger

  @moduledoc """
  The supervisor for all hardware (sensor / motor) hats that can
  be interfaced with.
  Calls to the -hardware_command- interface make the appropriate python api call
  to query the hardware.

  If you are adding a new python hardware api, please implement a setup function
  in the python module.
  Then please add the module name to the environment it is able to be run from
  in the :supported_hardware config variable
  """

  ####
  #config
  @script_dir "#{Application.get_env(:blockytalky, Blockytalky.Endpoint, __DIR__)[:root]}/lib/hw_apis"
  @supported_hardware Application.get_env(:blockytalky, :supported_hardware)

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
    hw_children = for hw <- @supported_hardware do
      case hw do
        :btbrickpi ->
            [worker(PythonQuerier, [hw], id: hw, restart: :transient),
             worker(Blockytalky.BrickPiState,[])]
        _ -> worker(PythonQuerier, [hw], id: hw, restart: :transient)
      end
    end
    |> List.flatten
    Logger.debug "Starting HW Workers: #{inspect hw_children}"
    supervise hw_children, strategy: :one_for_one, max_restarts: 5, max_seconds: 1
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
  {python_env, python_module}

  we can query the GenServer in order to run the script with those args.
  Name keyword can be any of: #{inspect Application.get_env(:blockytalky, :supported_hardware)}
  """

  ####
  #External API - should only be called by HardwareDaemon
  def start_link(python_module) do
    {:ok, python_env} = :python.start([{:python_path,String.to_char_list(@script_dir)}])
    Logger.debug "PythonQuerier: Started with module: #{inspect python_module}"
    status = {:ok, _pid} = GenServer.start_link(__MODULE__, {python_env, python_module}, name: python_module)
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

  def init(python_env, python_module) do
    #trap exit
    #:erlang.process_flag(:trap_exit, true)
    #return state
    {:ok, {python_env, python_module}}
  end

  def handle_call({:run, method, args}, _from, state={python_env, python_module}) do
    #erlport run the script
    Logger.debug "About to run #{inspect python_module}.#{inspect method}(#{inspect args})"
    result = :python.call(python_env, python_module, method, args)
    Logger.debug "Result: #{inspect result}"
    #return result and keep state unchanged
    {:reply, {:ok, result}, state}
  end

  def handle_cast({:run, method, args},state={python_env, python_module}) do
    #runscript
    result = try do
      :python.call(python_env, python_module, method, args)
       {:noreply,state}
    rescue
      e in ErlangError ->
        #if the cast failed on setup, then we don't want to restart the module, but if it was just a bad method call, we do.
        reason = if method == :setup, do: :shutdown, else: :abnormal
        {:stop, reason, state}
    end
    result

  end
#  def handle_info({:exit, _pid, reason}, state) do
#    Logger.debug "#{inspect reason}"
#    {:noreply, state}
#  end
  def terminate(reason, {python_env, python_module}) do
    #clean up env
    Logger.info "Terminating: #{inspect python_module} with reason: #{inspect reason}."
    case reason do
      :shutdown ->
        Logger.info "This module is not going to restart, please make sure you have the correct environment for your python modules."
      _ ->
        Logger.info "Restarting... UI should repoll port types from state server and reset them."
    end
    :python.stop(python_env)
  end
end
