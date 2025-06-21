defmodule PhoenixVite.MixProject do
  use Mix.Project

  def project do
    [
      app: :phoenix_vite,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      dialyzer: [plt_add_apps: [:mix]]
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
      {:igniter, "~> 0.6", optional: true},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    colored_mix = "elixir --erl \"-elixir\\ ansi_enabled\\ true\" -S mix"

    [
      checks: [
        "cmd #{colored_mix} deps.unlock --check-unused",
        "cmd #{colored_mix} xref graph --format cycles --label compile-connected --fail-above 0",
        "cmd #{colored_mix} format --check-formatted",
        "cmd #{colored_mix} compile --force --warnings-as-errors",
        "cmd #{colored_mix} dialyzer#{if System.get_env("CI"), do: " --format github"}"
      ]
    ]
  end
end
