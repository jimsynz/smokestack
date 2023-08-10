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
  @spec factory(Smokestack.t(), Resource.t(), atom) :: {:ok, Factory.t()} | :error
  def factory(factory, resource, variant) do
    factory
    |> Extension.get_entities([:smokestack])
    |> Enum.find(&(is_struct(&1, Factory) && &1.resource == resource && &1.variant == variant))
    |> case do
      nil -> :error
      factory -> {:ok, factory}
    end
  end
end
