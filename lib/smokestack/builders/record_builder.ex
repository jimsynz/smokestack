defmodule Smokestack.RecordBuilder do
  @moduledoc """
  Handles the insertion of new records.
  """

  alias Ash.{Resource, Seed}
  alias Smokestack.{Builder, Dsl.Factory, ManyBuilder, RelatedBuilder}
  alias Spark.Options
  @behaviour Builder

  @type option :: load_option | ManyBuilder.option() | RelatedBuilder.option()

  @typedoc "A nested keyword list of associations, calculations and aggregates to load"
  @type load_option :: {:load, Smokestack.recursive_atom_list()}

  @type result :: Resource.record() | [Resource.record()]
  @type error ::
          RelatedBuilder.error()
          | ManyBuilder.error()
          | Ash.Error.t()

  @doc """
  Run the factory and insert a record, or records.
  """
  @impl true
  @spec build(Factory.t(), [option]) :: {:ok, result} | {:error, error}
  def build(factory, options) do
    {count, options} = Keyword.pop(options, :count)
    do_build(factory, options, count)
  end

  @doc false
  @impl true
  @spec option_schema(nil | Factory.t()) :: {:ok, Options.schema()} | {:error, error}
  def option_schema(factory) do
    with {:ok, related_schema} <- RelatedBuilder.option_schema(factory),
         {:ok, many_schema} <- ManyBuilder.option_schema(factory) do
      load_type =
        if factory do
          loadable_names =
            factory.resource
            |> Resource.Info.relationships()
            |> Enum.concat(Resource.Info.aggregates(factory.resource))
            |> Enum.concat(Resource.Info.calculations(factory.resource))
            |> Enum.map(& &1.name)
            |> Enum.uniq()

          {:or,
           [
             {:wrap_list, {:in, loadable_names}},
             {:keyword_list,
              Enum.map(
                loadable_names,
                &{&1, type: {:or, [:atom, :keyword_list]}, required: false}
              )}
           ]}
        else
          {:or, [{:wrap_list, :atom}, :keyword_list]}
        end

      many_schema =
        Keyword.update!(many_schema, :count, fn current ->
          current
          |> Keyword.update!(:type, &{:or, [&1, nil]})
          |> Keyword.put(:default, nil)
          |> Keyword.put(:required, false)
        end)

      schema =
        [
          load: [
            type: load_type,
            required: false,
            default: [],
            doc: """
            An optional Ash load statement.

            You can request any calculations, aggregates or relationships you
            would like loaded on the returned record.

            For example:

            ```elixir
            insert!(Post, load: [:full_title])
            assert is_binary(post.full_title)
            ```
            """
          ]
        ]
        |> Options.merge(many_schema, "Options for building multiple instances")
        |> Options.merge(related_schema, "Options for building relationships")

      {:ok, schema}
    end
  end

  defp do_build(factory, options, count) when is_integer(count) and count > 0 do
    {load, options} = Keyword.pop(options, :load, [])
    options = Keyword.put(options, :count, count)

    with {:ok, attr_list} <- Builder.build(ManyBuilder, factory, options),
         {:ok, record_list} <- seed(attr_list, factory) do
      record_list
      |> maybe_hook(factory)
      |> maybe_load(factory, load)
    end
  end

  defp do_build(factory, options, _count) do
    {load, options} = Keyword.pop(options, :load, [])

    with {:ok, attrs} <- Builder.build(RelatedBuilder, factory, options),
         {:ok, record} <- seed(attrs, factory) do
      record
      |> maybe_hook(factory)
      |> maybe_load(factory, load)
    end
  end

  defp seed(attr_list, factory) when is_list(attr_list) do
    records =
      factory.resource
      |> Seed.seed!(attr_list)
      |> Enum.map(&set_meta(&1, factory))

    {:ok, records}
  rescue
    error -> {:error, error}
  end

  defp seed(attrs, factory) do
    record =
      factory.resource
      |> Seed.seed!(attrs)
      |> set_meta(factory)

    {:ok, record}
  rescue
    error -> {:error, error}
  end

  defp set_meta(record, factory) do
    record
    |> Resource.put_metadata(:factory, factory.module)
    |> Resource.put_metadata(:variant, factory.variant)
  end

  defp maybe_load(record_or_records, _factory, []), do: {:ok, record_or_records}

  defp maybe_load(_record_or_records, factory, _load) when is_nil(factory.domain),
    do: {:error, "Unable to perform `load` operation without an Domain."}

  defp maybe_load(record_or_records, factory, load),
    do: Ash.load(record_or_records, load, domain: factory.domain)

  defp maybe_hook(records, factory) when is_list(records) do
    Enum.map(records, fn record ->
      Enum.reduce(factory.after_build, record, fn hook, record ->
        hook.(record)
      end)
    end)
  end

  defp maybe_hook(record, factory) when is_map(record) do
    Enum.reduce(factory.after_build, record, fn hook, record ->
      hook.hook.(record)
    end)
  end
end
