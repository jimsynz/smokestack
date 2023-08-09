defmodule Smokestack.MixProject do
  use Mix.Project

  @version "0.1.0"

  @moduledoc """
  Test factories for Ash resources.
  """

  def project do
    [
      app: :smokestack,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: @moduledoc,
      package: package(),
      source_url: "https://code.harton.nz/james/smokestack",
      homepage_url: "https://code.harton.nz/james/smokestack",
      aliases: aliases()
    ]
  end

  def package do
    [
      maintainers: ["James Harton <james@harton.nz>"],
      licenses: ["HL3-FULL"],
      links: %{
        "Source" => "https://code.harton.nz/james/smokestack"
      }
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Smokestack.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  # Run "mix help deps" to learn about dependencies.
  defp deps do
    opts = [only: ~w[dev test]a, runtime: false]

    [
      {:ash, "~> 2.13"},
      {:spark, "~> 1.1"},
      {:credo, "~> 1.7", opts},
      {:dialyxir, "~> 1.3", opts},
      {:doctor, "~> 0.21", opts},
      {:earmark, ">= 0.0.0", opts},
      {:ex_check, "~> 0.15", opts},
      {:ex_doc, ">= 0.0.0", opts},
      {:git_ops, "~> 2.6", opts},
      {:mix_audit, "~> 2.1", opts}
    ]
  end

  defp aliases do
    [
      "spark.formatter": "spark.formatter --extensions=Smokestack.Resource,Smokestack.Factory"
    ]
  end
end
