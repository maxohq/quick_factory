defmodule QuickFactory.MixProject do
  use Mix.Project

  def project do
    [
      app: :quick_factory,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
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

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.0"},
      {:faker, ">= 0.0.0"},
      {:ecto_sql, "~> 3.0", only: [:test, :dev], optional: true},
      {:postgrex, "~> 0.16", only: [:test, :dev], optional: true}
    ]
  end
end
