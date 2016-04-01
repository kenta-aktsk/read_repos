defmodule ReadRepos.Mixfile do
  use Mix.Project

  @version "0.0.1"

  def project do
    [app: :read_repos,
     version: @version,
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps, 

     # Hex
     description: description,
     package: package]
  end

  defp description do
    """
    Simple master-slave library for Ecto.
    """
  end

  defp package do
    [maintainers: ["Kenta Katsumata"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/kenta-aktsk/read_repos"},
     files: ~w(mix.exs README.md LICENSE lib)]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  defp deps do
    []
  end
end
