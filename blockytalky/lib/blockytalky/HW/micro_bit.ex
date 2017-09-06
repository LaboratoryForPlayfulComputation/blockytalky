defmodule Blockytalky.MicroBit do
	alias Blockytalky.PythonQuerier, as: PythonQuerier
	require Logger

	def send_value(data) do
                PythonQuerier.run(:microbit,:uart_send,[data])
                
               :ok
        end  
        def serial_wrap(deli,data1) do
               PythonQuerier.run(:microbit,:uart_wrapper,[deli,data1])             
	       
               :ok
        end
        def send_number(value) do
               PythonQuerier.run(:microbit,:uart_send,[value])
               
               :ok
        end
end



#Internal API

  ####
  # GenServer Implementation
  # CH. 16
defmodule Blockytalky.MicrobitState do
        use GenServer
        require Logger
        def start_link() do
		GenServer.start_link(__MODULE__, [], name: __MODULE__)
	end
        def init(_) do
		Logger.info("Initializing #{inspect __MODULE__}")
		{:ok, %{}}
	end
        def terminate(_reason,_state) do
		Logger.info("Terminating #{inspect __MODULE__}")
	end
end
