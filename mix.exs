defmodule Emeck.Mixfile do
  use Mix.Project

  def project do
    [
      app: :emeck,
      version: "0.1.0",
      elixir: "~> 1.3",
      elixirc_paths: elixirc_paths(Mix.env),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      deps: deps(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
      name: "emeck",
      source_url: "https://github.com/bencode/emeck"
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  defp description do
    """
    A Mocking library for Elixir language. It's implemented based on meck.
    """
  end

  defp deps do
    [
      {:meck, "~> 0.8"},
      {:credo, "~> 0.7", only: [:dev, :test]},
      {:httpoison, "~> 0.11", only: :test},
      {:excoveralls, "~> 0.5", only: :test},
      {:ex_doc, "~> 0.15", only: :dev}
    ]
  end

  defp package do
    %{
      licenses: ["MIT"],
      maintainers: ["bencode"],
      links: %{
        "GitHub" => "https://github.com/bencode/emeck"
      }
    }
  end
end
