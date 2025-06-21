defmodule PhoenixVite.MixProject do
  use Mix.Project

  def project do
    [
      app: :phoenix_vite,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_live_view, "~> 1.0"},
      {:bun, "~> 1.4", optional: true, runtime: false},
      {:igniter, "~> 0.6", optional: true}
    ]
  end
end
