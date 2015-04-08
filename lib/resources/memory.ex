defmodule Resources.Memory do
  @moduledoc """
  Uses linux's proc system for gathering memory information about the system.
  
  Returns total memory and memory free in kB.
  """
  
  @type t :: list | map
  @type a :: atom

  @doc """
  Return Dict of cpu utilization from /proc/meminfo
  
  ## Examples
  
      iex> Resources.Memory.info
      [mem_free: 2614052, mem_total: 4044756]
  
  """
  @spec info :: t | {:error, a}
  def info do
    case :os.type do
      {:unix, :linux} ->
        case :file.open('/proc/meminfo', [:read]) do
          {:ok, f} ->
            {:ok, contents} = :file.read(f, 4096)
            :file.close(f)
            process(:string.tokens(contents, ': \n'), [])
          {:error, message} -> {:error, message}
        end
      {:unix, :darwin} -> {:osx, :not_supported}
      {family, _name} -> {family, :not_supported}
    end
  end
    

  defp process(['MemTotal', t, 'kB' | rest], result) do
      process(rest, [{:mem_total, :erlang.list_to_integer(t)} | result])
  end
  defp process(['MemFree', t, 'kB' | rest], result) do
      process(rest, [{:mem_free, :erlang.list_to_integer(t)} | result])
  end
  defp process([_x, _y, 'kB' | rest], result), do: process(rest, result)
  defp process([_x, '0' | rest], result), do: process(rest, result)
  defp process([], result), do: result
end