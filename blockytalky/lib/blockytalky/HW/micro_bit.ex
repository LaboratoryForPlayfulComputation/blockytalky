defmodule Blockytalky.MicroBit do
	alias Blockytalky.PythonQuerier, as: PythonQuerier
        alias Blockytalky.MicrobitState, as: MicrobitState
	require Logger

	def send_value(data) do
                PythonQuerier.run(:microbit,:uart_send,[data])
                Logger.info("looping")
               :ok
        end  
        def serial_wrap(deli,data1) do
               PythonQuerier.run(:microbit,:uart_wrapper,[deli,data1])             
	       Logger.info("looping")
               :ok
        end
        def send_number(value) do
               PythonQuerier.run(:microbit,:uart_no,[value])
               Logger.info("Wrapper for number")
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