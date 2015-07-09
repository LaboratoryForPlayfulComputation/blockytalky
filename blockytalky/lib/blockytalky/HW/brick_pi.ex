defmodule Blockytalky.BrickPi do
  alias Blockytalky.PythonQuerier, as: PythonQuerier
  alias Blockytalky.BrickPiState, as: BrickPiState
  require Logger

  @moduledoc """
  API for BrickPi calls.
  """
  ####
  #config
  @script_dir "#{Application.get_env(:blockytalky, Blockytalky.Endpoint, __DIR__)[:root]}/lib/hw_apis"
  @supported_hardware Application.get_env(:blockytalky, :supported_hardware)
  ####
  #External API

  def get_sensor_value(port_id) do
    port_num = BrickPiState.get_sensor_type_constants[port_id]
    type = BrickPiState.get_sensor_type(port_id)
    value = case type do
      "TYPE_SENSOR_NONE" -> nil
      _ -> PythonQuerier.run_result(:btbrickpi, :get_sensor_value,[port_num])
      end

    type = BrickPiState.get_sensor_type(port_id)
    #normalize from brickpi to blockytalky values here:
    value = case value do
      {:ok, v} -> v
      v -> v
    end
    case type do
      _ -> value
    end
  end
  def get_encoder_value(port_id) do
     port_num = BrickPiState.get_sensor_type_constants[port_id]
     case PythonQuerier.run_result(:btbrickpi, :get_encoder_value,[port_num]) do
       {:ok, v} -> v
       _ -> nil
     end
   end
  @doc """
  ##Example
      iex>Blockytalky.BrickPi.set_sensor_type("PORT_1","TYPE_SENSOR_TOUCH")
  """
  def set_sensor_type(port_id, sensor_type) do
     if sensor_type != "TYPE_SENSOR_NONE" do
       BrickPiState.set_sensor_type(port_id, sensor_type)
       num_type = BrickPiState.get_sensor_type_constants[sensor_type]
       port_num = BrickPiState.get_sensor_type_constants[port_id]
       PythonQuerier.run(:btbrickpi, :set_sensor_type, [port_num, num_type])
    end
  end
   @doc """
   ##Example
      iex>Blockytalky.BrickPi.set_sensor_type(0,"TYPE_SENSOR_TOUCH")
      iex>Blockytalky.BrickPi.get_sensor_type(0)
      {:ok, "TYPE_SENSOR_TOUCH"}
   """
   def get_sensor_type(port_id) do
    case BrickPiState.get_sensor_type(port_id) do
      {:ok, value} -> value
      value -> value
    end
   end
   def get_sensor_type_constants, do: BrickPiState.get_sensor_type_constants
   def set_motor_value(port_id, value) do
    new_value = _normalize(value, [low: -100, high: 100], [low: -255, high: 255])
    port_num = BrickPiState.get_sensor_type_constants[port_id]
    PythonQuerier.run(:btbrickpi, :set_motor_value,[port_num, new_value])
  end
  #notmalized an int from its % in one range to another.
  # int * [low: int, high: int] * [low: int, high: int] -> int
  #example:
  # _normalize(50,[low:-100,100], [low:-255, high:255]) #=> 127
  defp _normalize(value, from, to)  do
    (value - from[:low])
    |> (&(&1 * (to[:high] - to[:low]))).()
    |> (&(div(&1,(from[:high] - from[:low])))).()
    |> (&(&1 + to[:low])).()
  end
end

defmodule Blockytalky.BrickPiState do
  use GenServer
  #CH 16 Programming Elixir
  require Logger
  @moduledoc """
  The genserver, launched by the HardwareDaemon when :btbrickpi is in the supported_hardware
  list, that handles the state of the brickpi object
  It loads the type constants for the brick pi sensors once upon init (and again on restart if crashed)
  When the BrickPi api is called to set/get a sensor's type, this module updates it's
  state to reflect that new type. The state looks like:
  {map_of_constants=%{"KEY" => int...}, port_list=[:"1":"KEY1",:"3":"KEY2"]}
  """
  @sensor_dir "#{Application.get_env(:blockytalky, Blockytalky.Endpoint, __DIR__)[:root]}/data/"
  @sensor_file "sensors.json"
  @script_dir "#{Application.get_env(:blockytalky, Blockytalky.Endpoint, __DIR__)[:root]}/lib/hw_apis"
  @no_sensor "TYPE_SENSOR_NONE"
  def start_link() do
    {:ok, _pid} = GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end
  def init(_) do
    # {:ok, %{"TYPE_NAME"=> value, ...},[:"1":num, ...]}
    map = _get_sensor_type_constants
    #reload last known configuration of sensor types
    File.mkdir(@sensor_dir)
    File.touch("#{@sensor_dir}/#{@sensor_file}")
    sensor_types = case File.read("#{@sensor_dir}/#{@sensor_file}") do
      {:ok, text} when text != "" -> JSX.decode(text)
      _ -> %{}
    end
    {:ok, {map, sensor_types}}
  end
  # () -> {:ok,%{"type"=>num...}}
  def get_sensor_type_constants, do: GenServer.call(__MODULE__, {:get_sensor_type_constants})
  #int * "key" -> ()
  def set_sensor_type(port_id, sensor_type), do: GenServer.cast(__MODULE__, {:set_sensor_type, port_id, sensor_type})
  # int -> "key"
  def get_sensor_type(port_id), do: GenServer.call(__MODULE__, {:get_sensor_type, port_id})

  def handle_call({:get_sensor_type_constants}, _from, state={constants, _sensor_port_types}) do
    {:reply,constants, state}
  end
  def handle_call({:get_sensor_type, port_id}, _from, state={constants, sensor_types}) do
    type = Map.get(sensor_types,port_id,@no_sensor)
    {:reply,type, state}
  end
  def handle_cast({:set_sensor_type,port_id, sensor_type},{constants, sensor_types}) do
    sensor_types = Map.put(sensor_types,port_id, sensor_type)
    #backup sensor types
    {status, json} = JSX.encode sensor_types
    if status == :ok, do: File.write(@sensor_file, json)
    {:noreply,{constants, sensor_types}}
  end
  def terminate(_reason, _state) do
  end

  ####
  #Helper functions to load the SENSOR_TYPE_CONSTANTS from BrickPi.py via parsing.
  defp _get_sensor_type_constants do
    Logger.debug "BrickPiState: BrickPi.py for constants and put them in a keyword list"
    _get_sensor_type_constants([])
    |> _convert_constants_list_to_map
    |> _hardcoded_values
    |> (fn map -> #turn string values into int values
      for {key,value} <- map, into: %{}, do: {key, String.to_integer(value)}
      end).()
  end

  defp _get_sensor_type_constants(list, file \\ nil) do
    #open file
    unless file, do: file = File.open!("#{@script_dir}/BrickPi.py")
    #parse through to find constant declarations at the top of the file
    line = IO.read(file, :line) |> String.strip
    #match = ~r/^([A-Z_]+)(\s*)=(\s*)(((0x)*)[0-9]|[A-Z_]+)/
    match = ~r/^[0-9A-Z_]+\s*=\s*[0-9]+/
    cond do
      #line is a constant definition: starts with an all caps var name and is assigned a numberic value
      line =~ match -> _get_sensor_type_constants( Regex.run(match,line) ++ list, file)
      #stop when the line starts with keywords: def or class
      line =~ ~r/^(def|class)/ -> list
      #otherwise recurse on next line
      true -> _get_sensor_type_constants(list, file)
    end

  end
  defp _convert_constants_list_to_map(list) do
    map = for str <- list, into: %{}  do
      pair = String.split(str, "=")
      [key | [value]] = pair
      key = String.strip key
      value = String.strip value
      {key, value}
    end
  end
  #The values that Brickpi has weirdness on that are too hard to parse and
  #aren't likely to change. Feel free to replace with a better regex later.
  defp _hardcoded_values(map) do
    map
    |> Map.put("TYPE_SENSOR_LIGHT_ON","9") #Dexter Industries are unlikely to change this.
    |> Map.put(@no_sensor, "-1") #for display purposes. different than 'raw' (0)
  end
end
