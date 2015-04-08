defmodule ResourcesTest do
  use ExUnit.Case

  test "Cpu returns information" do
    case :os.type do
      {:unix, :linux} ->
        dict = Resources.Cpu.info
        assert is_list(dict)
        #one_min = Dict.get dict, :load_1_min
        #assert is_number(String.to_float(one_min))
      {family, _name} -> flunk "#{inspect family} OS not supported"
    end
  end   
  
  test "Memory returns information" do
    case :os.type do
      {:unix, :linux} ->
        dict = Resources.Memory.info
        assert is_list(dict)
      {family, _name} -> flunk "#{inspect family} OS not supported"
    end
  end 
  
  test "Disk returns information" do
    case :os.type do
      {:unix, :linux} ->
        dict = Resources.Disk.info
        assert is_list(dict)
      {family, _name} -> flunk "#{inspect family} OS not supported"
    end
  end  
end