defmodule Smokestack.RecordBuilder do
  @moduledoc """
  Handles the insertion of new records.
  """

  alias Ash.{Resource, Seed}
  alias Smokestack.{Dsl.Info, ParamBuilder}

  @insert_option_defaults %{load: []}

  @type insert_options :: ParamBuilder.param_options() | [load_option()]

  @typedoc "A nested keyword list of associations, calculations and aggregates to load"
  @type load_option :: {:load, Smokestack.recursive_atom_list()}

  @type insert_result :: Resource.record()

  @doc """
  Insert a resource record with a factory.
  """
  @spec build(Smokestack.t(), Resource.t(), map, atom, insert_options) ::
          {:ok, insert_result()} | {:error, any}
  def build(factory_module, resource, overrides \\ %{}, variant \\ :default, options \\ [])
      when is_atom(factory_module) and is_atom(resource) and is_atom(variant) and is_list(options) do
    with {:ok, insert_opts, param_opts} <- split_options(options),
         {:ok, factory} <- Info.factory(factory_module, resource, variant),
         {:ok, params} <- ParamBuilder.build_factory(factory, overrides, param_opts),
         {:ok, record} <- do_seed(resource, params, factory_module, variant) do
      maybe_load(factory, record, insert_opts)
    end
  end

  @doc "Raising version of `build/5`"
  @spec build!(Smokestack.t(), Resource.t(), map, atom, insert_options) ::
          insert_result() | no_return
  def build!(factory_module, resource, overrides \\ %{}, variant \\ :default, options \\ []) do
    case build(factory_module, resource, overrides, variant, options) do
      {:ok, params} -> params
      {:error, reason} -> raise reason
    end
  end

  defp maybe_load(factory, record, options) do
    options
    |> Keyword.get(:load, [])
    |> List.wrap()
    |> case do
      [] ->
        {:ok, record}

      _loads when is_nil(factory.api) ->
        {:error, "Unable to perform `load` operation without an API."}

      loads ->
        factory.api.load(record, loads, [])
    end
  end

  defp do_seed(resource, params, factory_module, variant) do
    record =
      resource
      |> Seed.seed!(params)
      |> Resource.put_metadata(:factory, factory_module)
      |> Resource.put_metadata(:variant, variant)

    {:ok, record}
  rescue
    error -> {:error, error}
  end

  defp split_options(options) do
    {defaults, iopts, popts} =
      options
      |> Enum.reduce({@insert_option_defaults, [], []}, fn
        {key, value}, {defaults, iopts, popts} when is_map_key(defaults, key) ->
          {Map.delete(defaults, key), [{key, value} | iopts], popts}

        {key, value}, {defaults, iopts, popts} ->
          {defaults, iopts, [{key, value} | popts]}
      end)

    iopts =
      iopts
      |> Enum.concat(defaults)

    {:ok, iopts, popts}
  end
end
