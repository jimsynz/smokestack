defmodule Smokestack.RelatedBuilder do
  @moduledoc """
  Recursively build the factory and any related factories that have been
  requested.
  """

  alias Ash.Resource
  alias Smokestack.{Builder, Dsl.Factory, Dsl.Info, FactoryBuilder}
  alias Spark.Options
  @behaviour Builder

  @type option :: build_option | relate_option | FactoryBuilder.option()

  @typedoc """
  A nested keyword list of associations that should also be built.
  """
  @type build_option :: {:build, Smokestack.recursive_atom_list()}

  @typedoc """
  A nested keyword list of previously built records to explicitly associate to the new record.
  """
  @type relate_option :: {:relate, [{atom, Resource.record()}]}

  @type result :: %{optional(atom) => any}
  @type error :: FactoryBuilder.error() | Exception.t()

  @doc """
  Build related factories, if required.
  """
  @impl true
  @spec build(Factory.t(), [option]) :: {:ok, result} | {:error, error}
  def build(factory, options) do
    with {:ok, attrs} <- FactoryBuilder.build(factory, Keyword.drop(options, [:build, :relate])),
         {:ok, attrs} <- maybe_build_related(factory, attrs, options) do
      maybe_relate(factory, attrs, options)
    end
  end

  @doc false
  @impl true
  @spec option_schema(nil | Factory.t()) :: {:ok, Options.schema(), String.t()} | {:error, error}
  def option_schema(factory) do
    with {:ok, factory_schema, factory_section} <- FactoryBuilder.option_schema(factory) do
      build_type =
        if factory do
          relationship_names =
            factory.resource
            |> Resource.Info.relationships()
            |> Enum.map(& &1.name)

          {:or,
           [
             {:wrap_list, {:in, relationship_names}},
             {:keyword_list,
              Enum.map(
                relationship_names,
                &{&1, type: {:or, [:atom, :keyword_list]}, required: false}
              )}
           ]}
        else
          {:or, [{:wrap_list, :atom}, :keyword_list]}
        end

      relate_type =
        if factory do
          factory.resource
          |> Resource.Info.relationships()
          |> Enum.map(fn
            relationship when relationship.cardinality == :one ->
              {relationship.name, [type: {:struct, relationship.destination}, required: false]}

            relationship when relationship.cardinality == :many ->
              {relationship.name,
               [type: {:wrap_list, {:struct, relationship.destination}}, required: false]}
          end)
          |> case do
            [] -> :keyword_list
            keys -> {:or, [{:keyword_list, keys}]}
          end
        else
          :keyword_list
        end

      schema =
        [
          build: [
            type: build_type,
            required: false,
            default: [],
            doc: """
            A (nested) list of relationships to build.

            A (possibly nested) list of Ash resource relationships which is
            traversed building any instances as needed.

            For example:

            ```elixir
            post = insert!(Post, build: Author)
            assert is_struct(post.author, Author)
            ```

            Caveats:
            - When building for a variant other than `:default` a matching
              variant factory will be looked for and used if present, otherwise
              it will build the default variant instead.

            - Note that for relationships whose cardinality is "many" we only
              build one instance.

            If these caveats are an issue, then you can build them yourself and
            pass them in using the `relate` option.

            For example:

            ```elixir
            posts = insert!(Post, count: 3)
            author = insert(Author, relate: [posts: posts])
            ```
            """
          ],
          relate: [
            type: relate_type,
            required: false,
            default: [],
            doc: """
            A list of records to relate.

            For example

            ```elixir
            author = insert!(Author)
            post = insert!(Post, relate: [author: Author])
            ```
            """
          ]
        ]
        |> Options.merge(factory_schema, factory_section)

      {:ok, schema, "Options for building relationships"}
    end
  end

  defp maybe_build_related(factory, attrs, options) do
    options
    |> Keyword.get(:build, [])
    |> List.wrap()
    |> Enum.concat(factory.auto_build)
    |> Enum.map(fn
      {key, value} -> {key, value}
      key when is_atom(key) -> {key, []}
    end)
    |> remove_explicit_relates(options)
    |> Enum.reduce_while({:ok, attrs}, fn {relationship, nested_builds}, {:ok, attrs} ->
      case build_related(
             attrs,
             relationship,
             factory,
             Keyword.put(options, :build, nested_builds)
           ) do
        {:ok, attrs} -> {:cont, {:ok, attrs}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  defp remove_explicit_relates(builds, options) do
    relates =
      options[:relate]
      |> List.wrap()
      |> Map.new()

    builds
    |> Enum.reject(fn {key, _value} ->
      is_map_key(relates, key)
    end)
  end

  defp build_related(attrs, relationship, factory, options) do
    ash_relationship = Resource.Info.relationship(factory.resource, relationship)
    build_related(attrs, relationship, factory, options, ash_relationship)
  end

  defp build_related(_attrs, relationship, factory, _options, nil),
    do:
      {:error,
       ArgumentError.exception(
         message:
           "Relationship `#{inspect(relationship)}` is not defined on resource `#{inspect(factory.resource)}`."
       )}

  defp build_related(attrs, _, factory, options, relationship) do
    related_options =
      options
      |> Keyword.put(:attrs, %{})

    with {:ok, related_factory} <- find_related_factory(relationship.destination, factory),
         {:ok, related_attrs} <- __MODULE__.build(related_factory, related_options) do
      case relationship.cardinality do
        :one ->
          {:ok, Map.put(attrs, relationship.name, related_attrs)}

        :many ->
          {:ok, Map.put(attrs, relationship.name, [related_attrs])}
      end
    end
  end

  defp maybe_relate(factory, attrs, options) do
    options
    |> Keyword.get(:relate, [])
    |> List.wrap()
    |> Enum.map(fn {relationship, record} ->
      {relationship, record, Resource.Info.relationship(factory.resource, relationship)}
    end)
    |> Enum.reduce_while({:ok, attrs}, fn
      {relationship_name, _record, nil}, {:ok, _attrs} ->
        {:halt,
         {:error,
          "No relationship named `#{inspect(relationship_name)}` defined on resource `#{inspect(factory.resource)}`"}}

      {_, record, relationship}, {:ok, attrs} ->
        case relate(attrs, relationship, record) do
          {:ok, attrs} -> {:cont, {:ok, attrs}}
          {:error, reason} -> {:halt, {:error, reason}}
        end
    end)
  end

  defp relate(attrs, relationship, record)
       when is_struct(record, relationship.destination) and relationship.cardinality == :one,
       do: {:ok, Map.put(attrs, relationship.name, record)}

  defp relate(_attrs, relationship, record) when relationship.cardinality == :one,
    do:
      {:error,
       "Expected value to be a `#{inspect(relationship.destination)}` record, however it is #{inspect(record)}"}

  defp relate(attrs, relationship, records) when relationship.cardinality == :many do
    records
    |> Enum.reduce_while({:ok, []}, fn
      record, {:ok, records} when is_struct(record, relationship.destination) ->
        {:cont, {:ok, [record | records]}}

      record, _ ->
        {:halt,
         {:error,
          "Expected value to be a `#{inspect(relationship.destination)}` record, however it is #{inspect(record)}"}}
    end)
    |> case do
      {:ok, records} -> {:ok, Map.put(attrs, relationship.name, records)}
      {:error, reason} -> {:error, reason}
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
           "No factory variant named `#{inspect(factory.variant)}` or `:default` found on `#{inspect(factory.resource)}`."
       )}
    end
  end
end
