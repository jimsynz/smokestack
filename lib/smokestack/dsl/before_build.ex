defmodule Smokestack.Dsl.BeforeBuild do
  @moduledoc """
  The `before_build` DSL entity.

  See `d:Smokestack.factory.before_build` for more information.
  """

  defstruct __identifier__: nil, hook: nil

  alias Spark.Dsl.Entity

  @type attrs :: %{required(String.t() | atom) => any}
  @type t :: %__MODULE__{
          __identifier__: any,
          hook: mfa | (attrs -> attrs)
        }

  @doc false
  @spec __entities__ :: [Entity.t()]
  def __entities__,
    do: [
      %Entity{
        name: :before_build,
        describe: """
        Modify the attributes before building.

        Allows you to provide a function which can modify the the attributes before building.
        """,
        target: __MODULE__,
        args: [:hook],
        identifier: {:auto, :unique_integer},
        schema: [
          hook: [
            type: {:mfa_or_fun, 1},
            required: true,
            doc: "A function which returns an updated record"
          ]
        ]
      }
    ]
end
