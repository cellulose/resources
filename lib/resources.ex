defmodule Resources do
  @moduledoc """
  Simple tool to get system resource information.
  
  Sub Modules really should be called directly.
  
  Note: Currently requires Hub which should be extracted and implemented as a
  callback.
  """
  
  @type t :: list | map
  
  @doc "Start the monitoring of the resources"
  @spec start_monitoring(t) :: {:ok, t}
  def start_monitoring(args \\ []) do
    Resources.Monitor.start(args)
  end
end