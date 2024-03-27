defmodule Smokestack.Builder do
  @moduledoc """
  A generic behaviour for "building things".
  """

  alias Smokestack.Dsl.Factory
  alias Spark.Options

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
  @callback option_schema(nil | Factory.t()) :: {:ok, Options.schema()} | {:error, any}

  @doc """
  Given a builder and a factory, validate it's options and call the builder.
  """
  @spec build(t, Factory.t(), Keyword.t()) :: {:ok, result} | {:error, error}
  def build(builder, factory, options) do
    with {:ok, schema} <- builder.option_schema(factory),
         {:ok, options} <- Options.validate(options, schema) do
      builder.build(factory, options)
    end
  end

  @doc """
  Generate documentation for the available options.
  """
  @spec docs(t, nil | Factory.t()) :: String.t()
  def docs(builder, factory) do
    {:ok, schema} = builder.option_schema(factory)
    Options.docs(schema)
  end
end
