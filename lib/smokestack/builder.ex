defmodule Smokestack.Builder do
  @moduledoc """
  A generic behaviour for "building things".
  """

  alias Smokestack.Dsl.Factory
  alias Spark.OptionsHelpers

  @type result :: any
  @type error :: any
  @type t :: module

  @doc """
  Given a Factory entity and some options build something.
  """
  @callback build(Factory.t(), Keyword.t()) :: {:ok, result} | {:error, error}

  @doc """
  Provide a schema for validating options.
  """
  @callback option_schema(Factory.t()) :: {:ok, OptionsHelpers.schema()} | {:error, any}

  @doc """
  Given a builder and a factory, validate it's options and call the builder.
  """
  @spec build(t, Factory.t(), Keyword.t()) :: {:ok, result} | {:error, error}
  def build(builder, factory, options) do
    with {:ok, schema} <- builder.option_schema(factory),
         {:ok, options} <- OptionsHelpers.validate(options, schema) do
      builder.build(factory, options)
    end
  end
end
