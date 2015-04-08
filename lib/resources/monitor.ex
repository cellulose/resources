defmodule Resources.Monitor do
  @moduledoc """
  Simple monitor of the system resources that gathers updated system information
  at regular interval.
  
  Currently this is dependent on Hub and should be reimplimented as a callback
  
  Also, this currently must monitor all known resources. Should be able to specify
  resources to monitor
  
  ## Options
  
  The `:period` options may be used to specify the refresh interval
  
  The `:path` option may be provided to specify the Hub path to update to
  
  ## Examples
  
  iex> Resources.Monitor.start
  {:ok, #PID<0.146.0>}
  
  iex> :hub.dump
  {{"0513306b4ce11109832c52258ccf661b", 1},
   [sys: {1,
     [resources: {1,
       [cpu: {1,
         [last_pid: {1, "16237"}, load_15_min: {1, "0.05"},
          load_1_min: {1, "0.00"}, load_5_min: {1, "0.01"},
          running_tasks: {1, "1/204"}]},
          .....
          ]}]}]}
  """
  use GenServer
  require Hub
  
  @slow_poll_period 5000 
  @point [:sys, :resource]
  
  
  @doc false
  def start(state \\ []) do
    #state_inspect = inspect(state, width: 32)
    GenServer.start __MODULE__, state, []
  end

  @doc false
  def start_link(state \\ []) do 
    GenServer.start_link __MODULE__, state, []
  end
  
  @doc false
  def init(args) do
    period = Dict.get args, :period, @slow_poll_period
    path = Dict.get args, :path, @point
    Process.send_after self, :slow_poll_trigger, period
    {:ok, Dict.merge(args, [path: path, period: period])}
  end
  
  @doc false
  def handle_info(:slow_poll_trigger, state) do
    Hub.update([:sys, :resources], 
                memory: Resources.Memory.info, 
                cpu: Resources.Cpu.info, 
                disks: Resources.Disk.info(state))
    Process.send_after self, :slow_poll_trigger, Dict.get(state, :period)
    {:noreply, state}
  end  
end