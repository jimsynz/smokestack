defmodule Smokestack.Dsl.Factory do
  @moduledoc """
  The `factory` DSL entity.

  See `d:Smokestack.factory` for more information.
  """

  defstruct __identifier__: nil,
            after_build: [],
            attributes: [],
            before_build: [],
            domain: nil,
            module: nil,
            resource: nil,
            variant: :default

  alias Ash.Resource
  alias Smokestack.Dsl.{AfterBuild, Attribute, BeforeBuild, Template}
  alias Spark.Dsl.Entity

  @type t :: %__MODULE__{
          __identifier__: any,
          after_build: [AfterBuild.t()],
          attributes: [Attribute.t()],
          before_build: [BeforeBuild.t()],
          domain: nil,
          module: module,
          resource: Resource.t(),
          variant: atom
        }

  @doc false
  @spec __entities__ :: [Entity.t()]
  def __entities__,
    do: [
      %Entity{
        name: :factory,
        describe: "Define factories for a resource",
        target: __MODULE__,
        args: [:resource, {:optional, :variant, :default}],
        imports: [Template],
        identifier: {:auto, :unique_integer},
        schema: [
          domain: [
            type: {:behaviour, Ash.Domain},
            required: false,
            doc: "The Ash Domain to use when evaluating loads"
          ],
          resource: [
            type: {:behaviour, Ash.Resource},
            required: true,
            doc: "An Ash Resource"
          ],
          variant: [
            type: :atom,
            required: false,
            doc: "The name of a factory variant",
            default: :default
          ]
        ],
        entities: [
          after_build: AfterBuild.__entities__(),
          attributes: Attribute.__entities__(),
          before_build: BeforeBuild.__entities__()
        ]
      }
    ]
end
