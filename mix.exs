defmodule Smokestack.MixProject do
  use Mix.Project

  @version "0.4.1"

  @moduledoc """
  Test factories for Ash resources.
  """

  def project do
    [
      app: :smokestack,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: Mix.env() != :test,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      description: @moduledoc,
      package: package(),
      source_url: "https://code.harton.nz/james/smokestack",
      homepage_url: "https://code.harton.nz/james/smokestack",
      aliases: aliases(),
      dialyzer: [plt_add_apps: [:faker]],
      docs: [
        main: "Smokestack",
        extra_section: "GUIDES",
        formatters: ["html"],
        filter_modules: ~r/^Elixir.Smokestack/,
        source_url_pattern:
          "https://code.harton.nz/james/smokestack/src/branch/main/%{path}#L%{line}",
        spark: [
          extensions: [
            %{
              module: Smokestack.Dsl,
              name: "Smokestack.Dsl",
              target: "Smokestack",
              type: "Smokestack"
            }
          ]
        ]
      ]
    ]
  end

  def package do
    [
      name: :smokestack,
      files: ~w[lib .formatter.exs mix.exs README* LICENSE* CHANGELOG* documentation],
      maintainers: ["James Harton <james@harton.nz>"],
      licenses: ["HL3-FULL"],
      links: %{
        "Source" => "https://code.harton.nz/james/smokestack",
        "Github Mirror" => "https://github.com/jimsynz/smokestack"
      },
      source_url: "https://code.harton.nz/james/smokestack"
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Smokestack.Application, []}
    ]
  end

  defp deps do
    opts = [only: ~w[dev test]a, runtime: false]

    [
      {:ash, "~> 2.13"},
      {:credo, "~> 1.7", opts},
      {:dialyxir, "~> 1.3", opts},
      {:doctor, "~> 0.21", opts},
      {:earmark, ">= 0.0.0", opts},
      {:ex_check, "~> 0.15", opts},
      {:ex_doc, ">= 0.0.0", opts},
      {:faker, "~> 0.17", opts},
      {:git_ops, "~> 2.6", opts},
      {:mix_audit, "~> 2.1", opts},
      {:recase, "~> 0.7"},
      {:spark, "~> 1.1 and >= 1.1.39"}
    ]
  end

  defp aliases do
    [
      "spark.formatter": "spark.formatter --extensions=Smokestack.Dsl",
      "spark.cheat_sheets": "spark.cheat_sheets --extensions=Smokestack.Dsl"
    ]
  end

  defp elixirc_paths(env) when env in ~w[dev test]a, do: ~w[lib test/support]
  defp elixirc_paths(_), do: ~w[lib]
end
