defmodule Coyote.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :coyote,
      name: "Coyote",
      version: @version,
      elixir: "~> 1.3",
      deps: deps(),
      package: package()
    ]
  end

  def application do
    [applications: [:logger, :cowboy, :mime],
     mod: {Coyote, []}]
  end

  defp deps do
    [
      {:mime, "~> 1.0"},
      {:cowboy, "~> 1.1"}
    ]
  end

  defp package do
    %{licenses: ["Apache 2"],
      maintainers: ["Johnny Winn"],
      links: %{"GitHub" => "https://github.com/nurugger07/coyote"}}
  end
end
