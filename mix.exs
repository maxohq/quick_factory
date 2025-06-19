defmodule QuickFactory.MixProject do
  use Mix.Project
  @github_url "https://github.com/maxohq/quick_factory"
  @version "0.2.0"

  def project do
    [
      app: :quick_factory,
      version: @version,
      description:
        "QuickFactory - plain yet powerful factory for Ecto with support for changesets",
      source_url: @github_url,
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {QuickFactory.Application, []}
    ]
  end

  defp package do
    [
      files: ~w(lib mix.exs README* CHANGELOG*),
      licenses: ["MIT"],
      links: %{
        "GitHub" => @github_url,
        "Changelog" => "#{@github_url}/blob/main/CHANGELOG.md"
      }
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.0"},
      {:ecto_sql, "~> 3.0", only: [:test, :dev], optional: true},
      {:postgrex, "~> 0.16", only: [:test, :dev], optional: true},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false}
    ]
  end
end
