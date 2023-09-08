defmodule Smokestack do
  alias Spark.{Dsl, Dsl.Extension}

  @moduledoc """
  Smokestack provides a way to define test factories for your 
  [Ash Resources](https://ash-hq.org/docs/module/ash/latest/ash-resource) 
  using a convenient DSL:

  ```
  defmodule MyApp.Factory do
    use Smokestack

    factory Character do
      attribute :name, &Faker.StarWars.character/0
      attribute :affiliation, choose(["Galactic Empire", "Rebel Alliance"])
    end
  end

  defmodule MyApp.CharacterTest do
    use MyApp.DataCase
    use MyApp.Factory

    test "it can build a character" do
      assert character = insert!(Character)
    end
  end
  ```

  ## Variants

  Sometimes you need to make slightly different factories to build a resource
  in a specific state for your test scenario.  

  Here's an example defining an alternate `:trek` variant for the character
  factory defined above:

  ```
  factory Character, :trek do
    attribute :name, choose(["J.L. Pipes", "Severn", "Slickback"])
    attribute :affiliation, choose(["Entrepreneur", "Voyager"])
  end
  ```

  ## Building resource records

  You can use `insert/2` and `insert!/2` to build and insert records.  Records
  are inserted using `Ash.Seed.seed/2`, which means that they bypass the usual
  Ash lifecycle (actions, validations, etc).

  ### Options

  - `load`: an atom, list of atoms or keyword list of the same listing 
    relationships, calculations and aggregates that should be loaded
    after the record is created.
  - `count`: rather than inserting just a single record, you can specify a
    number of records to be inserted.  A list of records will be returned.
  - `build`: an atom, list of atoms or keyword list of the same describing
    relationships which you would like built alongside the record.  If the
    related resource has a variant which matches the current one, it will be
    used, and if not the `:default` variant will be.
  - `attrs`: A map or keyword list of attributes you would like to set directly
    on the created record, rather than using the value provided by the factory.

  ## Building parameters

  As well as inserting records directly you can use `params/2` and `params!/2`
  to build parameters for use testing controller actions, HTTP requests, etc.

  ### Options

  - `encode`: rather than returning a map or maps, provide an encoder module
    to serialise the parameters.  Commonly you would use `Jason` or `Poison`.
  - `nest`: rather than returning a map or maps directly, wrap the result in
    an outer map using the provided key.
  - `key_case`: change the case of the keys into one of the many cases
    supported by [recase](https://hex.pm/packages/recase).
  - `key_type`: specify whether the returned map or maps should use string or
    atom keys (ignored when using the `encode` option).
  - `count`: rather than returning just a single map, you can specify a
    number of results to be returned.  A list of maps will be returned.
  - `build`: an atom, list of atoms or keyword list of the same describing
    relationships which you would like built within the result.  If the
    related resource has a variant which matches the current one, it will be
    used, and if not the `:default` variant will be.
  - `attrs`: A map or keyword list of attributes you would like to set directly
    on the result, rather than using the value provided by the factory.

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

        defmacro __using__(_) do
          quote do
            import __MODULE__
          end
        end

        defoverridable params: 2,
                       params!: 2,
                       insert: 2,
                       insert!: 2,
                       __using__: 1
      end
    ] ++ super(opts)
  end
end
