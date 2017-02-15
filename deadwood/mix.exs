defmodule Deadwood.Mixfile do
  use Mix.Project

  def project do
    [app: :deadwood,
     version: "0.1.0",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :coyote],
     mod: {Deadwood, []}]
  end

  defp deps do
    [
      {:coyote, in_umbrella: true}
    ]
  end
end
