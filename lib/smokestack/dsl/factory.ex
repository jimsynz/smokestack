defmodule Smokestack.Dsl.Factory do
  @moduledoc """
  The `factory` DSL entity.

  See `d:Smokestack.factory` for more information.
  """

  defstruct __identifier__: nil,
            after_build: [],
            attributes: [],
            auto_load: [],
            auto_build: [],
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
          auto_load: [atom] | Keyword.t(),
          auto_build: [atom],
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
          ],
          auto_build: [
            type: {:wrap_list, :atom},
            required: false,
            doc: "A list of relationships that should always be built when building this factory",
            default: []
          ],
          auto_load: [
            type: {:wrap_list, {:or, [:atom, :keyword_list]}},
            required: false,
            doc: "An Ash \"load statement\" to always apply when building this factory",
            default: []
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
