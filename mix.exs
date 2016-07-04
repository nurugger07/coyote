defmodule Coyote.Mixfile do
  use Mix.Project

  def project do
    [app: :coyote,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :cowboy]]
  end

  defp deps do
    [{:cowboy, "~> 1.0"}]
  end
end
