defmodule Blockytalky.GrovePi do
	alias Blockytalky.PythonQuerier, as: PythonQuerier
	alias Blockytalky.GrovePiState, as: GrovePiState
	require Logger
	
	def port_id_map do
		%{:A0 => {0, "analog"}, :A1 => {1, "analog"}, :A2 => {2, "analog"}, :D2 => {2, "digital"},
			:D3 => {3, "PWM"}, :D4 => {4, "digital"}, :D5 => {5, "PWM"}, :D6 => {6, "PWM"}, 
			:D7 => {7, "digital"}, :D8 => {8, "digital"}}
	end

	def component_id_map do 
		%{:LIGHT => "INPUT", :SOUND => "INPUT", :ROTARY_ANGLE => "INPUT",
			:BUTTON => "INPUT", :BUZZER => "OUTPUT", :LED => "OUTPUT",
			:RELAY => "OUTPUT", :TEMP_HUM => "DHT", :ULTRASONIC => "ULTRASONIC",:O2_SENSOR => "OUTPUT"}
	end 
	def get_component_value(port_id) do
		{port_num, type} = Map.get(port_id_map, port_id,{nil,nil})
		io = GrovePiState.get_port_io(port_id)
                case io do
		   "OUTPUT" -> GrovePiState.get_last_set_value(port_id) 
<<<<<<< HEAD
                    "DHT"    ->
=======
		   "DHT"    ->
>>>>>>> 4b69db249dae0a228a8e02435b37ca691d481c44
		        {_,v} = PythonQuerier.run_result(:btgrovepi,:get_sensor_value,[port_num,type,io])		
		        case v do
			  [t,h] -> [t,h]
			  _     -> nil
			end
                    _ -> 
			{_,v} = PythonQuerier.run_result(:btgrovepi,:get_sensor_value,[port_num,type,io])		
		        if v == "Error", do: nil, else: v
	        end
	end
	
	def set_component_type(port_id, component_id) do
		{port_num, _} = Map.get(port_id_map, port_id)
		component_io = Map.get(component_id_map, component_id)
		PythonQuerier.run(:btgrovepi, :set_sensor_type, [port_num, component_io])
		GrovePiState.set_component_type(port_id, component_id)
		:ok
	end
	
	def set_component_value(port_id, value) do
		{port_num, type} = Map.get(port_id_map, port_id)
		value = case type do
			"digital" -> cond do 
				value > 1 -> 1
				value < 0 -> 0
				true -> value
				end
			"analog" -> cond do
				value > 1023 -> 1023
				value < 0 -> 0
				true -> value
				end
			"PWM" -> cond do
				value > 255 -> 255
				value < 0 -> 0
				true -> value
				end
		end
		PythonQuerier.run(:btgrovepi, :set_component, [port_num, value, type])
                GrovePiState.set_component_value(port_id, value)
		:ok		
	end           
end

defmodule Blockytalky.GrovePiState do
	use GenServer
	alias Blockytalky.GrovePi, as: GrovePi
	require Logger
	def start_link() do
		GenServer.start_link(__MODULE__, [], name: __MODULE__)
	end
	def init(_) do
		Logger.info("Initializing #{inspect __MODULE__}")
		{:ok, %{}}
	end
	def set_component_type(port_id, component_id) do
		GenServer.cast(__MODULE__, {:set_port, port_id, component_id})		
	end
        def set_component_value(port_id, value) do
                GenServer.cast(__MODULE__, {:set_value, port_id, value})
        end
	def get_last_set_value(port_id) do
                GenServer.call(__MODULE__, {:get_last_set_value, port_id})
        end
	def get_port_io(port_id) do
		Map.get(GrovePi.component_id_map, get_port_component(port_id))
	end
        def get_port_component(port_id) do
                { component_id, _ } = GenServer.call(__MODULE__, {:get_port, port_id})
		component_id
        end
	def terminate(_reason,_state) do
		Logger.info("Terminating #{inspect __MODULE__}")
	end
	def handle_call({:get_port, port_id}, _from, map) do
		{:reply, Map.get(map, port_id, {nil, nil}), map}
	end
        def handle_call({:get_last_set_value, port_id}, _from, map) do
                { _, value} = Map.get(map, port_id, {nil, nil})
                {:reply, value, map}
        end
	def handle_cast({:set_port, port_id, component_id}, map) do	
		map = Map.put(map, port_id, {component_id, nil})
		{:noreply, map}
	end
        def handle_cast({:set_value, port_id, value}, map) do
		{ component_id, _ } = Map.get(map, port_id, {nil, nil})
		map = Map.put(map, port_id, { component_id, value })
                {:noreply, map}
        end	
end
