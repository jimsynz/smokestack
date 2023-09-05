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

  See `Smokestack.ParamBuilder.build/2` for more information.
  """
  @callback params(Resource.t(), ParamBuilder.param_options()) ::
              {:ok, ParamBuilder.param_result()} | {:error, any}

  @doc """
  Raising version of `params/2`.

  Automatically implemented by modules which `use Smokestack`.

  See `Smokestack.ParamBuilder.build/3` for more information.
  """
  @callback params!(Resource.t(), ParamBuilder.param_options()) ::
              ParamBuilder.param_result() | no_return

  @doc """
  Runs a factory and uses it to insert an Ash Resource into it's data layer.

  Automatically implemented by modules which `use Smokestack`.

  See `Smokestack.RecordBuilder.build/3` for more information.
  """
  @callback insert(Resource.t(), RecordBuilder.insert_options()) ::
              {:ok, Resource.record()} | {:error, any}

  @doc """
  Raising version of `insert/4`.

  Automatically implemented by modules which `use Smokestack`.

  See `Smokestack.RecordBuilder.build/3` for more information.
  """
  @callback insert!(Resource.t(), RecordBuilder.insert_options()) ::
              Resource.record() | no_return

  @doc false
  defmacro __using__(opts) do
    [
      quote do
        @behaviour Smokestack

        @doc """
        Execute the matching factory and return a map or list of params.

        See `Smokestack.ParamBuilder.build/3` for more information.
        """
        @spec params(Resource.t(), ParamBuilder.param_options()) ::
                {:ok, ParamBuilder.param_result()} | {:error, any}
        def params(resource, options \\ []),
          do: ParamBuilder.build(__MODULE__, resource, options)

        @doc """
        Raising version of `params/2`.

        See `Smokestack.ParamBuilder.build/3` for more information.
        """
        @spec params!(Resource.t(), ParamBuilder.param_options()) ::
                ParamBuilder.param_result() | no_return
        def params!(resource, options \\ []),
          do: ParamBuilder.build!(__MODULE__, resource, options)

        @doc """
        Execute the matching factory and return an inserted Ash Resource record.

        See `Smokestack.RecordBuilder.build/3` for more information.
        """
        @spec insert(Resource.t(), RecordBuilder.insert_options()) ::
                {:ok, Resource.record()} | {:error, any}
        def insert(resource, options \\ []),
          do: RecordBuilder.build(__MODULE__, resource, options)

        @doc """
        Raising version of `insert/2`.

        See `Smokestack.RecordBuilder.build/3` for more information.
        """
        @spec insert!(Resource.t(), RecordBuilder.insert_options()) ::
                Resource.record() | no_return
        def insert!(resource, options \\ []),
          do: RecordBuilder.build!(__MODULE__, resource, options)

        defoverridable params: 2,
                       params!: 2,
                       insert: 2,
                       insert!: 2
      end
    ] ++ super(opts)
  end
end
