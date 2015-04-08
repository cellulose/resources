defmodule Resources.Mixfile do
  use Mix.Project

  def project do
    [app: :resources,
     version: "0.3.0",
     elixir: "~> 1.0",
     deps: deps]
  end
  
  def application, do: [
      mod:          { Echo, [] },
      applications: [ ],
      env:          [ ]
  ]

  defp deps do
    [{ :echo, git: "git@github.com:ghitchens/echo.git", branch: :dev}]
  end
end
