defmodule Smokestack.FactoryBuilder do
  @moduledoc """
  Executes a factory and returns it's result.
  """

  alias Ash.Resource
  alias Smokestack.{Builder, Dsl.Attribute, Dsl.Factory, Template}
  alias Spark.OptionsHelpers
  @behaviour Builder

  @type option :: attrs_option

  @typedoc """
  Manually specify some attributes.
  """
  @type attrs_option :: {:attrs, Enumerable.t({atom, any})}

  @type result :: %{optional(atom) => any}
  @type error :: any

  @doc """
  Execute the named factory, if possible.
  """
  @impl true
  @spec build(Factory.t(), [option]) :: {:ok, result} | {:error, error}
  def build(factory, options) do
    overrides = options[:attrs]

    factory
    |> Map.get(:attributes, [])
    |> Enum.filter(&is_struct(&1, Attribute))
    |> Enum.reduce({:ok, %{}}, fn
      attr, {:ok, attrs} when is_map_key(overrides, attr.name) ->
        {:ok, Map.put(attrs, attr.name, Map.get(overrides, attr.name))}

      attr, {:ok, attrs} ->
        generator = maybe_initialise_generator(attr)
        value = Template.generate(generator, attrs, options)
        {:ok, Map.put(attrs, attr.name, value)}
    end)
  end

  @doc false
  @impl true
  @spec option_schema(Factory.t()) ::
          {:ok, OptionsHelpers.schema()} | {:error, error}
  def option_schema(factory) do
    attr_keys =
      factory.resource
      |> Resource.Info.attributes()
      |> Enum.map(&{&1.name, [type: :any, required: false]})

    {:ok,
     [
       attrs: [
         type: :map,
         required: false,
         default: %{},
         keys: attr_keys
       ]
     ]}
  end

  defp maybe_initialise_generator(attr) do
    with nil <- Process.get(attr.__identifier__),
         generator <- Template.init(attr.generator) do
      Process.put(attr.__identifier__, generator)
      generator
    end
  end
end
