defmodule Smokestack.Builder do
  @moduledoc """
  A generic behaviour for "building things".
  """

  alias Ash.Resource
  alias Smokestack.Dsl.{Factory, Info}
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
  @callback option_schema(nil | Factory.t()) ::
              {:ok, Options.schema(), String.t()} | {:error, any}

  @doc """
  Find the appropriate factory, validate options and run the builder.
  """
  @spec build(Smokestack.t(), Resource.t(), t, Keyword.t()) :: {:ok, result} | {:error, error}
  def build(factory_module, resource, builder, options) do
    with {:ok, our_schema} <- variant_schema(factory_module, resource),
         {:ok, factory} <- Info.factory(factory_module, resource, options[:variant] || :default),
         {:ok, builder_schema, section} <- builder.option_schema(factory),
         schema <- Options.merge(our_schema, builder_schema, section),
         {:ok, options} <- Options.validate(options, schema) do
      builder.build(factory, options)
    end
  end

  @doc """
  Generate documentation for the available options.
  """
  @spec docs(t, nil | Factory.t()) :: String.t()
  def docs(builder, factory) do
    {:ok, schema, _} = builder.option_schema(factory)
    Options.docs(schema)
  end

  defp variant_schema(factory_module, resource) do
    case Info.variants(factory_module, resource) do
      [] ->
        {:error,
         "There are no factories defined for the resource `#{inspect(resource)}` in the `#{inspect(factory_module)}` module."}

      variants ->
        our_schema = [
          variant: [
            type: {:in, variants},
            required: false,
            default: :default,
            doc: """
            The name of the factory variant to use.
            """
          ]
        ]

        {:ok, our_schema}
    end
  end
end
