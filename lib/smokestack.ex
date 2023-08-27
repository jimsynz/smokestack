defmodule Smokestack do
  alias Spark.{Dsl, Dsl.Extension}

  @moduledoc """

  <!--- ash-hq-hide-start --> <!--- -->

  ## DSL Documentation

  ### Index

  #{Extension.doc_index(Smokestack.Dsl.sections())}

  ### Docs

  #{Extension.doc(Smokestack.Dsl.sections())}

  <!--- ash-hq-hide-stop --> <!--- -->
  """

  use Dsl, default_extensions: [extensions: [Smokestack.Dsl]]
  alias Ash.Resource
  alias Smokestack.{ParamBuilder, RecordBuilder}

  @type t :: module

  @type recursive_atom_list :: atom | [atom | {atom, recursive_atom_list()}]

  @doc """
  Runs a factory and uses it to build a map or list of results.

  Automatically implemented by modules which `use Smokestack`.

  See `Smokestack.ParamBuilder.build/5` for more information.
  """
  @callback params(Resource.t(), map, atom, ParamBuilder.param_options()) ::
              {:ok, ParamBuilder.param_result()} | {:error, any}

  @doc """
  Raising version of `params/4`.

  Automatically implemented by modules which `use Smokestack`.

  See `Smokestack.ParamBuilder.build/5` for more information.
  """
  @callback params!(Resource.t(), map, atom, ParamBuilder.param_options()) ::
              ParamBuilder.param_result() | no_return

  @doc """
  Runs a factory and uses it to insert an Ash Resource into it's data layer.

  Automatically implemented by modules which `use Smokestack`.

  See `Smokestack.RecordBuilder.build/5` for more information.
  """
  @callback insert(Resource.t(), map, atom, RecordBuilder.insert_options()) ::
              {:ok, Resource.record()} | {:error, any}

  @doc """
  Raising version of `insert/4`.

  Automatically implemented by modules which `use Smokestack`.

  See `Smokestack.RecordBuilder.build/5` for more information.
  """
  @callback insert!(Resource.t(), map, atom, RecordBuilder.insert_options()) ::
              Resource.record() | no_return

  @doc false
  defmacro __using__(opts) do
    [
      quote do
        @behaviour Smokestack

        @doc """
        Execute the matching factory and return a map or list of params.

        See `Smokestack.ParamBuilder.build/5` for more information.
        """
        @spec params(Resource.t(), map, atom, ParamBuilder.param_options()) ::
                {:ok, ParamBuilder.param_result()} | {:error, any}
        def params(resource, overrides \\ %{}, variant \\ :default, options \\ []),
          do: ParamBuilder.build(__MODULE__, resource, overrides, variant, options)

        @doc """
        Raising version of `params/4`.

        See `Smokestack.ParamBuilder.build/5` for more information.
        """
        @spec params!(Resource.t(), map, atom, ParamBuilder.param_options()) ::
                ParamBuilder.param_result() | no_return
        def params!(resource, overrides \\ %{}, variant \\ :default, options \\ []),
          do: ParamBuilder.build!(__MODULE__, resource, overrides, variant, options)

        @doc """
        Execute the matching factory and return an inserted Ash Resource record.

        See `Smokestack.RecordBuilder.build/5` for more information.
        """
        @spec insert(Resource.t(), map, atom, RecordBuilder.insert_options()) ::
                {:ok, Resource.record()} | {:error, any}
        def insert(resource, overrides \\ %{}, variant \\ :default, options \\ []),
          do: RecordBuilder.build(__MODULE__, resource, overrides, variant, options)

        @doc """
        Raising version of `insert/4`.

        See `Smokestack.RecordBuilder.build/5` for more information.
        """
        @spec insert!(Resource.t(), map, atom, RecordBuilder.insert_options()) ::
                Resource.record() | no_return
        def insert!(resource, overrides \\ %{}, variant \\ :default, options \\ []),
          do: RecordBuilder.build!(__MODULE__, resource, overrides, variant, options)

        defoverridable params: 4,
                       params!: 4,
                       insert: 4,
                       insert!: 4
      end
    ] ++ super(opts)
  end
end
