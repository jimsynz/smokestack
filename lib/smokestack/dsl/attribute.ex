defmodule Smokestack.Dsl.Attribute do
  @moduledoc """
  The `attribute ` DSL entity.

  See `d:Smokestack.factory.default.attribute` for more information.
  """

  defstruct __identifier__: nil, generator: nil, name: nil

  alias Ash.Resource
  alias Spark.Dsl.Entity

  @type t :: %__MODULE__{
          __identifier__: nil,
          generator:
            mfa | (-> any) | (Resource.record() -> any) | (Resource.record(), keyword -> any),
          name: atom
        }

  @doc false
  @spec __entities__ :: [Entity.t()]
  def __entities__,
    do: [
      %Entity{
        name: :attribute,
        target: __MODULE__,
        args: [:name, :generator],
        identifier: {:auto, :unique_integer},
        schema: [
          name: [
            type: :atom,
            required: true,
            doc: "The name of the target attribute"
          ],
          generator: [
            type:
              {:or,
               [
                 {:mfa_or_fun, 0},
                 {:mfa_or_fun, 1},
                 {:mfa_or_fun, 2},
                 #  {:protocol, Smokestack.Template}
                 {:struct, Smokestack.Template.Choose},
                 {:struct, Smokestack.Template.Constant},
                 {:struct, Smokestack.Template.Cycle},
                 {:struct, Smokestack.Template.NTimes},
                 {:struct, Smokestack.Template.Sequence}
               ]},
            required: true,
            doc: """
            A function which can generate an appropriate value for the attribute.œ
            """
          ]
        ]
      }
    ]
end
