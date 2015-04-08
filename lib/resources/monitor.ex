defmodule Resources.Monitor do
  @moduledoc ~S"""
  Simple monitor of the system resources that gathers updated system information
  at regular interval.
  
  Also, this currently must monitor all known resources. Should be able to specify
  resources to monitor
  
  ## Examples

      iex> Resources.Monitor.start(callback: fn(args) -> IO.write "#{inspect args}" end)
      {:ok, #PID<0.146.0>}
      [memory: [mem_free: 2614052, mem_total: 4044756], cpu: ....]
  """
  use GenServer
  
  @slow_poll_period 5000
  
  @type t :: list | map
  @type on_start :: {:ok, pid} | :ignore | {:error, {:already_started, pid} | term}

  @doc ~S"""
  Start the montitoring process as a `GenServer` process linked to the current process.
  
  This is often used to start the monitor as part of a supervision tree.
  
  Accepts a Dict of initialization options, and if provided will override
  the default values.
  
  ## Options

  The `:callback` option is used to specify how the returned Dicts from various
  submodules is handled. This is to be a function/1 where the paramater is
  a Dict. `Default: fn(_) -> true end`

  The `:period` options may be used to specify the refresh interval. Default: 5000

  ## Examples

      iex> Resources.Monitor.start(callback: fn(args) -> IO.write "#{inspect args}" end)
      {:ok, #PID<0.146.0>}
      [memory: [mem_free: 2614052, mem_total: 4044756], cpu: ....]
  """
  @spec start_link(t) :: on_start
  def start_link(state \\ []) do
    state = setup_state(state)
    GenServer.start_link __MODULE__, state, []
  end
  

  @doc """
  Starts a monitoring process as a `GenServer` without links (outside of a supervision tree).
  See `start_link/3` for more information.
  """
  @spec start(t) :: on_start
  def start(state \\ []) do
    state = setup_state(state)
    GenServer.start __MODULE__, state, []
  end
  
  @doc false
  def init(state) do
    Process.send_after self, :slow_poll_trigger, Dict.get(state, :period)
    {:ok, state}
  end
  
  @doc false
  def handle_info(:slow_poll_trigger, state) do
    callback = Dict.get state, :callback
    callback.(memory: Resources.Memory.info,
              cpu: Resources.Cpu.info,
              disks: Resources.Disk.info(state))
    Process.send_after self, :slow_poll_trigger, Dict.get(state, :period)
    {:noreply, state}
  end  

  # Setups up initial state by parsing args and using defaults if key not found
  defp setup_state(args) do
    period = Dict.get args, :period, @slow_poll_period
    callback = Dict.get args, :callback, fn(_) -> true end
    [period: period, callback: callback]
  end
end