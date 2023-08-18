defmodule Smokestack.Dsl.Factory do
  @moduledoc """
  The `factory` DSL entity.

  See `d:Smokestack.factory` for more information.
  """

  defstruct __identifier__: nil, attributes: [], resource: nil, variant: :default

  alias Ash.Resource
  alias Smokestack.Dsl.{Attribute, Template}
  alias Spark.Dsl.Entity

  @type t :: %__MODULE__{
          __identifier__: any,
          attributes: [Attribute.t()],
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
        entities: [attributes: Attribute.__entities__()]
      }
    ]
end
