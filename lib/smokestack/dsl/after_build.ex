defmodule Smokestack.Dsl.AfterBuild do
  @moduledoc """
  The `after_build` DSL entity.

  See `d:Smokestack.factory.after_build` for more information.
  """

  defstruct __identifier__: nil, hook: nil

  alias Ash.Resource
  alias Spark.Dsl.Entity

  @type t :: %__MODULE__{
          __identifier__: any,
          hook: mfa | (Resource.record() -> Resource.record())
        }

  @doc false
  @spec __entities__ :: [Entity.t()]
  def __entities__,
    do: [
      %Entity{
        name: :after_build,
        describe: """
        Modify the record after building.

        Allows you to provide a function which can modify the built record before returning.

        These hooks are only applied when building records and not parameters.
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
