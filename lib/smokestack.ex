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
  alias Smokestack.{Builder, Dsl.Info, ParamBuilder, RecordBuilder}

  @type t :: module

  @type recursive_atom_list :: atom | [atom | {atom, recursive_atom_list()}]
  @type param_option :: variant_option | ParamBuilder.option()
  @type insert_option :: variant_option | RecordBuilder.option()

  @typedoc """
  Choose a factory variant to use.  Defaults to `:default`.
  """
  @type variant_option :: {:variant, atom}

  @doc """
  Runs a factory and uses it to build a parameters suitable for simulating a
  request.

  Automatically implemented by modules which `use Smokestack`.

  See `Smokestack.ParamBuilder.build/2` for more information.
  """
  @callback params(Resource.t(), [param_option]) ::
              {:ok, ParamBuilder.result()} | {:error, any}

  @doc """
  Raising version of `params/2`.

  Automatically implemented by modules which `use Smokestack`.

  See `Smokestack.ParamBuilder.build/3` for more information.
  """
  @callback params!(Resource.t(), [param_option]) :: ParamBuilder.result() | no_return

  @doc """
  Runs a factory and uses it to insert Ash resources into their data layers.

  Automatically implemented by modules which `use Smokestack`.

  See `Smokestack.RecordBuilder.build/3` for more information.
  """
  @callback insert(Resource.t(), [insert_option]) ::
              {:ok, RecordBuilder.result()} | {:error, any}

  @doc """
  Raising version of `insert/4`.

  Automatically implemented by modules which `use Smokestack`.

  See `Smokestack.RecordBuilder.build/3` for more information.
  """
  @callback insert!(Resource.t(), [insert_option]) :: RecordBuilder.result() | no_return

  @doc false
  defmacro __using__(opts) do
    [
      quote do
        @behaviour Smokestack

        @doc """
        Runs a factory and uses it to build a parameters suitable for simulating a
        request.

        See `c:Smokestack.build/2` for more information.
        """
        @spec params(Resource.t(), [Smokestack.param_option()]) ::
                {:ok, ParamBuilder.result()} | {:error, any}
        def params(resource, options \\ []) do
          {variant, options} = Keyword.pop(options, :variant, :default)

          with {:ok, factory} <- Info.factory(__MODULE__, resource, variant) do
            Builder.build(ParamBuilder, factory, options)
          end
        end

        @doc """
        Raising version of `params/2`.

        See `c:Smokestack.build/3` for more information.
        """
        @spec params!(Resource.t(), [Smokestack.param_option()]) ::
                ParamBuilder.result() | no_return
        def params!(resource, options \\ []) do
          case params(resource, options) do
            {:ok, result} -> result
            {:error, reason} -> raise reason
          end
        end

        @doc """
        Execute the matching factory and return an inserted Ash Resource record.

        See `c:Smokestack.insert/2` for more information.
        """
        @spec insert(Resource.t(), [Smokestack.insert_option()]) ::
                {:ok, RecordBuilder.result()} | {:error, any}
        def insert(resource, options \\ []) do
          {variant, options} = Keyword.pop(options, :variant, :default)

          with {:ok, factory} <- Info.factory(__MODULE__, resource, variant) do
            Builder.build(RecordBuilder, factory, options)
          end
        end

        @doc """
        Raising version of `insert/2`.

        See `c:Smokestack.insert/2` for more information.
        """
        @spec insert!(Resource.t(), [Smokestack.insert_option()]) ::
                RecordBuilder.result() | no_return
        def insert!(resource, options \\ []) do
          case insert(resource, options) do
            {:ok, result} -> result
            {:error, reason} -> raise reason
          end
        end

        defoverridable params: 2,
                       params!: 2,
                       insert: 2,
                       insert!: 2
      end
    ] ++ super(opts)
  end
end
