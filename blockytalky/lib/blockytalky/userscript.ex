defmodule Blockytalky.UserScript do
  use GenServer
  require Logger
  @moduledoc """
  Keeps track of the statful-ness of the client's BT program.
  e.g. hardware change over time, message queue to be handled
  Called by IR as needed to stash data between iterations
  state looks like:
  {[message queue], %{port_id => {new_value, old_value}}}
  """
  ####
  # External API
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
  @doc """
  applies the passed function with airity 2 to new value, and old value of
  the port with the passed id.
  (:id,(x,y) -> any) -> any
  ## Example
      iex> Blockytalky.UserScript.apply(fn(x,y) -> x > y end, :PORT_1)
  """
  def apply(fun, port_id) do
    {new_value, old_value} = GenServer.call(__MODULE__,{:get_value,port_id})
    fun.(new_value, old_value)
  end
  ####
  # Internal API


  ####
  # Genserver Implementation
  # Ch. 16 Programming Elixir

  def start_link() do
    GenServer.start_link(__MODULE__,[])
  end

  def init(_) do
    Logger.info "Starting #{inspect __MODULE__}"
    state = {[],%{}}
    {:ok, state}
  end
  def handle_call(:dequeue_message, _from, {mq, port_values}) when length(mq) > 0  do
    rev_q = Enum.reverse(mq)
    [value | new_q_rev] = rev_q
    new_q = Enum.reverse(new_q_rev)
    {:reply, {:ok, value}, {new_q,port_values}}
  end
  def handle_call(:dequeue_message, _from, s)  do
    {:reply, {:nomsg, :nomsg}, s}
  end
  def handle_call({:get_value, port_id}, _from, s={mq, port_values}) do
    value = Map.get(port_values, port_id, {:noval, :noval})
    {:reply, value, s}
  end
  def handle_cast({:put_value, value, port_id}, {mq,port_values}) do
    fetched_value = Map.get(port_values,port_id,{:noval,:noval})
    updated = case fetched_value do
      {:noval, :noval} ->
        {value, value}
      {new_value, old_value} ->
        {value, new_value}
    end

    {:noreply, { mq , Map.put(port_values,port_id,updated) } }
  end
  def handle_cast({:queue_message, msg}, {mq, port_values}) do
    {:noreply, {[msg | mq], port_values}}
  end
  def terminate(_reason, _state) do
    Logger.info "Terminating: #{inspect __MODULE__}"
  end

end
