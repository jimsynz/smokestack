defmodule Smokestack.Dsl.Info do
  @moduledoc """
  Introspection of Smokestack DSLs.
  """

  alias Ash.Resource
  alias Smokestack.Dsl.Factory
  alias Spark.Dsl.Extension

  @doc """
  Retrieve a variant for a specific resource.
  """
  @spec factory(Smokestack.t(), Resource.t(), atom) ::
          {:ok, Factory.t()} | {:error, Exception.t()}
  def factory(factory, resource, variant) do
    factory
    |> Extension.get_entities([:smokestack])
    |> Enum.find(&(is_struct(&1, Factory) && &1.resource == resource && &1.variant == variant))
    |> case do
      nil ->
        {:error,
         ArgumentError.exception(
           message: "Factory for `#{inspect(resource)}` variant `#{inspect(variant)}` not found."
         )}

      factory ->
        {:ok, factory}
    end
  end

  @doc "Raising version of `factory/3`"
  def factory!(factory, resource, variant) do
    case factory(factory, resource, variant) do
      {:ok, factory} -> factory
      {:error, reason} -> raise reason
    end
  end

  @doc """
  List all variants available for a resource.
  """
  @spec variants(Smokestack.t(), Resource.t()) :: [atom]
  def variants(factory, resource) do
    factory
    |> Extension.get_entities([:smokestack])
    |> Enum.filter(&(is_struct(&1, Factory) && &1.resource == resource))
    |> Enum.map(& &1.variant)
    |> Enum.uniq()
  end
end
