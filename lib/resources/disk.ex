defmodule Resources.Disk do
  @moduledoc """
  Uses linux command line utility `df` to get disk information.
  
  Can either gather information for all disks or filter disks by providing `:disks` option to
  info/1 method.
  """
  @type t :: list | map
  
  @doc """
  Returns Dict of disk usage from 'df' or an error
  
  ## Options
  
  The `:disks` options may be passed with a list of keys and mount points to filter on
  
  ##Examples
  
      iex> Resources.Disk.info
      [/: [Filesystem: "/dev/disk1", "512-blocks": "487867392", Used: "460837744",
        Available: "26517648", Capacity: "95%", iused: "57668716", ifree: "3314706",
        "%iused": "95%", Mounted: "/"],...]
      
      iex> Resources.Disk.info disks: [root: "/", dev: "/dev"]
      [root: [Filesystem: "/dev/disk1", "512-blocks": "487867392", Used: "460838792",
        Available: "26516600", Capacity: "95%", iused: "57668847", ifree: "3314575",
        "%iused": "95%", Mounted: "/"],
       dev: [Filesystem: "devfs", "512-blocks": "395", Used: "395", Available: "0",
        Capacity: "100%", iused: "685", ifree: "0", "%iused": "100%",
        Mounted: "/dev"]]
  """
  @spec info(t) :: t | {:error, :df_not_available}
  def info(args \\ []) do
    disks = Dict.get args, :disks, []
    case mounts do
      :error -> {:error, :df_not_available}
      mounts -> process_mounts(mounts, disks)
    end
  end
  
  # Uses df utility to determine disk information
  defp rawinfo do
    out = :os.cmd('df') |> List.to_string
    if String.contains?(out, "not found") do
      :error
    else
      out |> String.split("\n")
    end
  end
  
  # Takes first line from df to get headers
  defp headers do
    [raw_headers | _mounts] = rawinfo
    atomize_headers(raw_headers)
  end
  
  # convert string of headers to atoms
  # Note: removed `on` from `Mounted on`
  defp atomize_headers(s) do
    l = String.split(s) |> List.delete_at -1 
    List.foldr l, [], fn(h, acc) -> [String.to_atom h] ++ acc end
  end
  
  # Finds mount points of filesystem
  defp mounts do
    case rawinfo do
      [_ | mounts] -> mounts
      _ -> :error
    end
  end
  
  #Processes each line of the mounts list and zips the list
  #of headers with the disk information for the mount point
  defp process_mounts([], _disks) do
    []
  end

  defp process_mounts([h|t], disks \\ []) do
    # make sure h is not an empty string
    # it is possbile for the last line from 'df' to be empty
    if String.length(h) > 0 do
      disk_info = String.split(h)
      mnt_point = List.last disk_info
      # Check if we are filtering disks
      ret = if Enum.any?(disks) do
        # Return only those we are filtering on
        Enum.find_value disks, false, fn(d) ->
          {id, path} = d
          if path == mnt_point, do: Atom.to_string(id)
        end
      else
        # convert mnt_point to at
        mnt_point
      end
      if ret do
        ["#{ret}": Enum.zip(headers, disk_info)] ++ process_mounts(t, disks)
      else
        process_mounts(t, disks)
      end
    else
      process_mounts(t, disks)
    end
  end
end