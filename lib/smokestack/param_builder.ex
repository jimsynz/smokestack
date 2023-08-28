defmodule Smokestack.ParamBuilder do
  @moduledoc """
  Handles the building of parameters.
  """

  alias Ash.Resource
  alias Smokestack.{Dsl.Attribute, Dsl.Factory, Dsl.Info, Template}

  @param_option_defaults %{keys: :atom, as: :map, build: [], attrs: %{}, variant: :default}

  @typedoc "Options that can be passed to `params/4`."
  @type param_options :: [param_keys_option | param_as_option | build_option | param_variant]

  @typedoc "Key type in the result. Defaults to `#{inspect(@param_option_defaults[:keys])}`."
  @type param_keys_option :: {:keys, :atom | :string | :dasherise}

  @typedoc "Result type. Defaults to `#{inspect(@param_option_defaults[:as])}`"
  @type param_as_option :: {:as, :map | :list}

  @typedoc "Choose a specific factory variant. Defaults to `:default`."
  @type param_variant :: {:variant, atom}

  @typedoc "Specify attribute overrides."
  @type param_attrs :: {:attrs, Enumerable.t({atom, any})}

  @type param_result ::
          %{required(atom | String.t()) => any}
          | [{atom | String.t(), any}]

  @typedoc "A nested keyword list of associations that should also be built"
  @type build_option :: {:build, Smokestack.recursive_atom_list()}

  @doc """
  Build parameters for a resource with a factory.
  """
  @spec build(Smokestack.t(), Resource.t(), param_options) :: {:ok, param_result} | {:error, any}
  def build(factory_module, resource, options \\ [])
      when is_atom(factory_module) and is_atom(resource) and is_list(options) do
    with {:ok, options} <- validate_options(options),
         {:ok, factory} <- Info.factory(factory_module, resource, options[:variant]) do
      build_factory(factory, options)
    end
  end

  @doc "Raising version of `build/2..5`."
  @spec build!(Smokestack.t(), Resource.t(), param_options) :: param_result | no_return
  def build!(factory_module, resource, options \\ []) do
    case build(factory_module, resource, options) do
      {:ok, params} -> params
      {:error, reason} -> raise reason
    end
  end

  @doc false
  @spec build_factory(Factory.t(), param_options) :: {:ok, param_result()} | {:error, any}
  def build_factory(factory, options \\ []) do
    with {:ok, params} <- build_params(factory, options) do
      params =
        params
        |> maybe_stringify_keys(options)
        |> maybe_dasherise_keys(options)
        |> maybe_listify_result(options)

      {:ok, params}
    end
  end

  @doc false
  @spec validate_options(Enumerable.t({atom, any})) :: {:ok, param_options()}
  def validate_options(options) do
    opt_map = Map.new(options)

    Enum.reduce(@param_option_defaults, {:ok, []}, fn
      {key, _}, {:ok, options} when is_map_key(opt_map, key) ->
        {:ok, [{key, Map.get(opt_map, key)} | options]}

      {key, value}, {:ok, options} ->
        {:ok, [{key, value} | options]}
    end)
  end

  defp build_params(factory, options) do
    overrides = Map.new(options[:attrs])

    factory
    |> Map.get(:attributes, [])
    |> Enum.filter(&is_struct(&1, Attribute))
    |> Enum.reduce(%{}, fn
      attr, attrs when is_map_key(overrides, attr.name) ->
        Map.put(attrs, attr.name, Map.get(overrides, attr.name))

      attr, attrs ->
        generator = maybe_initialise_generator(attr)
        value = Template.generate(generator, attrs, options)
        Map.put(attrs, attr.name, value)
    end)
    |> maybe_build_related(factory, options)
  end

  defp maybe_build_related(params, factory, options) do
    options
    |> Keyword.get(:build, [])
    |> List.wrap()
    |> Enum.map(fn
      {key, value} -> {key, value}
      key when is_atom(key) -> {key, []}
    end)
    |> Enum.reduce_while({:ok, params}, fn {relationship, nested_builds}, {:ok, params} ->
      case build_related(
             params,
             relationship,
             factory,
             Keyword.put(options, :build, nested_builds)
           ) do
        {:ok, params} -> {:cont, {:ok, params}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  defp build_related(params, relationship, factory, options) do
    ash_relationship = Resource.Info.relationship(factory.resource, relationship)
    build_related(params, relationship, factory, options, ash_relationship)
  end

  defp build_related(_params, relationship, factory, _options, nil),
    do:
      {:error,
       "Relationship `#{inspect(relationship)}` not defined in resource `#{inspect(factory.resource)}`."}

  defp build_related(params, _, factory, options, relationship)
       when relationship.cardinality == :one do
    with {:ok, related_factory} <-
           find_related_factory(relationship.destination, factory),
         {:ok, related_params} <- build_params(related_factory, Keyword.put(options, :attrs, %{})) do
      {:ok, Map.put(params, relationship.name, related_params)}
    end
  end

  defp build_related(params, _, factory, options, relationship)
       when relationship.cardinality == :many do
    with {:ok, related_factory} <-
           find_related_factory(relationship.destination, factory),
         {:ok, related_params} <- build_params(related_factory, Keyword.put(options, :attrs, %{})) do
      {:ok, Map.put(params, relationship.name, [related_params])}
    end
  end

  defp find_related_factory(resource, factory) when factory.variant == :default,
    do: Info.factory(factory.module, resource, :default)

  defp find_related_factory(resource, factory) do
    with {:error, _} <- Info.factory(factory.module, resource, factory.variant),
         {:error, _} <- Info.factory(factory.module, resource, :default) do
      {:error,
       ArgumentError.exception(
         message:
           "Factory for `#{inspect(resource)}` no variant named `#{inspect(factory.variant)}` or `:default` found."
       )}
    end
  end

  defp maybe_initialise_generator(attr) do
    with nil <- Process.get(attr.__identifier__),
         generator <- Template.init(attr.generator) do
      Process.put(attr.__identifier__, generator)
      generator
    end
  end

  defp maybe_stringify_keys(attrs, options) do
    if Keyword.get(options, :keys, @param_option_defaults[:keys]) == :string do
      Map.new(attrs, fn {key, value} -> {Atom.to_string(key), value} end)
    else
      attrs
    end
  end

  defp maybe_dasherise_keys(attrs, options) do
    if Keyword.get(options, :keys, @param_option_defaults[:keys]) == :dasherise do
      Map.new(attrs, fn {key, value} ->
        key =
          key
          |> Atom.to_string()
          |> String.replace("_", "-")

        {key, value}
      end)
    else
      attrs
    end
  end

  defp maybe_listify_result(attrs, options) do
    if Keyword.get(options, :as, @param_option_defaults[:as]) == :list do
      Enum.to_list(attrs)
    else
      attrs
    end
  end
end
