defmodule Smokestack.Dsl.Transformer do
  @moduledoc false

  alias Ash.Resource.Info
  alias Smokestack.Dsl.Factory
  alias Spark.{Dsl, Dsl.Transformer, Error.DslError}
  use Transformer

  @doc false
  @spec transform(Dsl.t()) :: {:ok, Dsl.t()} | {:error, DslError.t()}
  def transform(dsl_state) do
    module = Transformer.get_persisted(dsl_state, :module)
    default_domain = Transformer.get_option(dsl_state, [:smokestack], :domain)

    dsl_state =
      dsl_state
      |> Transformer.get_entities([:smokestack])
      |> Enum.reduce(dsl_state, fn
        entity, dsl_state when is_struct(entity, Factory) ->
          resource_domain = Info.domain(entity.resource)

          entity = %{
            entity
            | module: module,
              domain: entity.domain || resource_domain || default_domain
          }

          Transformer.replace_entity(dsl_state, [:smokestack], entity)

        _, dsl_state ->
          dsl_state
      end)

    {:ok, dsl_state}
  end
end
