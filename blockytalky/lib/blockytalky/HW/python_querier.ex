
defmodule Blockytalky.PythonQuerier do
  use GenServer

  require Logger
  @script_dir "priv/hw_apis"
  @moduledoc """
  This is a Gen Server implementation that's job is to run the python scripts
  for interfacing with the BTU hardware (brick pi, grove pi, etc).
  continuously read values get put it into a stream for
  consumption by the userstate.

  The state our Genserver will keep track of is a tuple:
  {python_env, python_module}

  we can query the GenServer in order to run the script with those args.
  Name keyword can be any of: #{inspect Application.get_env(:blockytalky, :supported_hardware)}
  """

  ####
  #External API - should only be called by HardwareDaemon
  def start_link(python_module) do
    {:ok, python_env} = :python.start([{:python_path,String.to_char_list(Application.app_dir(:blockytalky, @script_dir))}])
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
  def run(name,method,args), do: GenServer.cast(name, {:run, method, args})
  @doc """
  nice wrapper for calling :run_result on the genserver. takes the python module name as an Atom,
   method (function) name, and [args]
  """
  def run_result(name,method, args), do: GenServer.call( name, {:run, method, args})
  ####
  #GenServer implementation
  # See: Ch16 of Programming Elixir

  def init(python_env, python_module) do
    Logger.info "Initializing #{inspect __MODULE__} :: #{inspect python_module}"
    #return state
    {:ok, {python_env, python_module}}
  end

  def handle_call({:run, method, args}, _from, state={python_env, python_module}) do
    #erlport run the script
    result = try do
        :python.call(python_env, python_module, method, args)
    rescue
        _ -> nil
    end
    #return result and keep state unchanged
    {:reply, {:ok, result}, state}
  end

  def handle_cast({:run, method, args},state={python_env, python_module}) do
    #runscript
    result = try do
      :python.call(python_env, python_module, method, args)
       {:noreply,state}
    rescue
      _e in ErlangError ->
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
