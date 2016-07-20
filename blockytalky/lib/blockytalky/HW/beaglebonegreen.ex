defmodule Blockytalky.BeagleBoneGreen do
	alias Blockytalky.PythonQuerier, as: PythonQuerier
	alias Blockytalky.BeagleBoneGreenState, as: BBGState
	require Logger
	
	def port_id_map do
		%{:I2C => {0, "analog"}, :UART => {1, "digital"}}
		#check if these IDs need to change to specific pins
	end

	def component_id_map do 
		%{:LIGHT => "INPUT", :SOUND => "INPUT", :ROTARY_ANGLE => "INPUT",
			:BUTTON => "INPUT", :BUZZER => "OUTPUT", :LED => "OUTPUT",
			:RELAY => "OUTPUT", :TEMP_HUM => "DHT", :ULTRASONIC => "ULTRASONIC"}
	end 
	def get_component_value(port_id) do
		{port_num, type} = Map.get(port_id_map, port_id,{nil,nil})
		io = BBGState.get_port_io(port_id)
            case io do
		   "OUTPUT" -> Logger.debug("getting last OUTPUT value")
		   			BBGState.get_last_set_value(port_id) 
	            _ -> 
	            	Logger.debug("getting INPUT value from python api ...")
					{_,v} = PythonQuerier.run_result(:beaglebonegreen,:get_sensor_value,[port_num,type,io])		
			        if v == "Error", do: nil, else: v
	        end
	end
	
	def set_component_type(port_id, component_id) do
		{port_num, _} = Map.get(port_id_map, port_id)
		component_io = Map.get(component_id_map, component_id)
		Logger.debug("setting sensor type ...")
		PythonQuerier.run(:beaglebonegreen, :set_sensor_type, [port_num, component_io])
		BBGState.set_component_type(port_id, component_id)
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
		end
		Logger.debug("setting component...")
		PythonQuerier.run(:beaglebonegreen, :set_component, [port_num, value, type])
        BBGState.set_component_value(port_id, value)
		:ok		
	end
end

defmodule Blockytalky.BeagleBoneGreenState do
	use GenServer
	alias Blockytalky.BeagleBoneGreen, as: BBG
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
		Map.get(BBG.component_id_map, get_port_component(port_id))
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
		Logger.debug("#{inspect map}")
		{:noreply, map}
	end
    def handle_cast({:set_value, port_id, value}, map) do
    	Logger.debug("adding value to port_values map")
		{ component_id, _ } = Map.get(map, port_id, {nil, nil})
		map = Map.put(map, port_id, { component_id, value })
        {:noreply, map}
    end	
end