defmodule Smokestack.MixProject do
  use Mix.Project

  @version "0.4.2"

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
      source_url: "https://harton.dev/james/smokestack",
      homepage_url: "https://harton.dev/james/smokestack",
      aliases: aliases(),
      dialyzer: [plt_add_apps: [:faker]],
      docs: [
        main: "readme",
        extra_section: "GUIDES",
        formatters: ["html"],
        filter_modules: ~r/^Elixir.Smokestack/,
        source_url_pattern:
          "https://harton.dev/james/smokestack/src/branch/main/%{path}#L%{line}",
        spark: [
          extensions: [
            %{
              module: Smokestack.Dsl,
              name: "Smokestack.Dsl",
              target: "Smokestack",
              type: "Smokestack"
            }
          ]
        ],
        extras:
          Enum.concat(
            ["README.md", "CHANGELOG.md"],
            Path.wildcard("documentation/**/*.{md,livemd,cheatmd}")
          ),
        groups_for_extras:
          "documentation/*"
          |> Path.wildcard()
          |> Enum.map(fn dir ->
            name =
              dir
              |> Path.split()
              |> List.last()
              |> String.split(~r/_+/)
              |> Enum.map_join(" ", &String.capitalize/1)

            files =
              dir
              |> Path.join("**.{md,livemd,cheatmd}")
              |> Path.wildcard()

            {name, files}
          end)
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
        "Source" => "https://harton.dev/james/smokestack",
        "Github Mirror" => "https://github.com/jimsynz/smokestack",
        "Changelog" => "https://docs.harton.nz/james/smokestack/changelog.html",
        "Sponsor" => "https://github.com/sponsors/jimsynz"
      },
      source_url: "https://harton.dev/james/smokestack"
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
      {:ash, "== 3.0.0-rc.0"},
      {:credo, "~> 1.7", opts},
      {:dialyxir, "~> 1.3", opts},
      {:doctor, "~> 0.21", opts},
      {:earmark, ">= 0.0.0", opts},
      {:ex_check, "~> 0.16", opts},
      {:ex_doc, ">= 0.0.0", opts},
      {:faker, "~> 0.18", opts},
      {:git_ops, "~> 2.6", opts},
      {:mix_audit, "~> 2.1", opts},
      {:recase, "~> 0.7"},
      {:spark, "~> 2.1"}
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
