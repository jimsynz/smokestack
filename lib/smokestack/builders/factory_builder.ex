defmodule Smokestack.FactoryBuilder do
  @moduledoc """
  Executes a factory and returns it's result.
  """

  alias Ash.Resource
  alias Smokestack.{Builder, Dsl.Factory, Template}
  alias Spark.Options
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
    overrides = Keyword.get(options, :attrs, %{})

    with {:ok, overrides} <- validate_overrides(factory, overrides) do
      attrs =
        factory.attributes
        |> remove_overridden_attrs(overrides)
        |> Enum.reduce(overrides, fn attr, attrs ->
          generator = maybe_initialise_generator(attr)
          value = Template.generate(generator, attrs, options)
          Map.put(attrs, attr.name, value)
        end)

      attrs =
        factory.before_build
        |> Enum.reduce(attrs, fn hook, attrs ->
          hook.hook.(attrs)
        end)

      {:ok, attrs}
    end
  end

  @doc false
  @impl true
  @spec option_schema(nil | Factory.t()) :: {:ok, Options.schema()} | {:error, error}
  def option_schema(factory) do
    attr_keys =
      if factory do
        factory.resource
        |> Resource.Info.attributes()
        |> Enum.map(&{&1.name, [type: :any, required: false]})
      else
        [{:*, [type: :any, required: false]}]
      end

    {:ok,
     [
       attrs: [
         type: :map,
         required: false,
         default: %{},
         keys: attr_keys,
         doc: """
         Attribute overrides.

         You can directly specify any overrides you would like set on the
         resulting record without running their normal generator.

         For example:

         ```elixir
         post = params!(Post, attrs: %{title: "What's wrong with Huntly?"})
         assert post.title == "What's wrong with Huntly?"
         ```
         """
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

  defp validate_overrides(factory, overrides) do
    valid_attr_names =
      factory.resource
      |> Resource.Info.attributes()
      |> Enum.map(& &1.name)

    Enum.reduce_while(overrides, {:ok, overrides}, fn {key, _}, {:ok, overrides} ->
      if key in valid_attr_names do
        {:cont, {:ok, overrides}}
      else
        {:halt,
         {:error,
          "No attribute named `#{inspect(key)}` available on resource `#{inspect(factory.resource)}`"}}
      end
    end)
  end

  defp remove_overridden_attrs(attrs, overrides) when map_size(overrides) == 0, do: attrs

  defp remove_overridden_attrs(attrs, overrides),
    do: Enum.reject(attrs, &is_map_key(overrides, &1.name))
end
