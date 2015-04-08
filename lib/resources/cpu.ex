defmodule Resources.Cpu do
  @moduledoc """
  Uses linux's proc system to find load averages and process information.
  """
  
  @type t :: list | map

  @doc """
  Return Dict of cpu utilization from /proc/loadvg
  
  ## Examples
      
      iex> Resources.Cpu.info
      [load_1_min: "0.00", load_5_min: "0.01", load_15_min: "0.05",
       running_tasks: "2/207", last_pid: "1553"]
  """
  @spec info :: t | {:error, :cpu_proc_not_available}
  def info do
    case rawinfo do
      {:ok, raws} ->
        Enum.zip [:load_1_min, :load_5_min, :load_15_min, :running_tasks, :last_pid], raws
      :error -> {:error, :cpu_proc_not_available}
    end
  end

  # reads /proc/loadavg to get CPU information and returns
  # string split or :error
  defp rawinfo do
    out = :os.cmd('cat /proc/loadavg')
    |> :erlang.list_to_binary
    
    if String.contains?(out, "No such file") do
      :error
    else
      {:ok, String.split out}
    end
  end    

end