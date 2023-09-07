defmodule Smokestack.ParamBuilder do
  @moduledoc """
  Handles the building of parameters.
  """

  alias Smokestack.{Builder, Dsl.Factory, ManyBuilder, RelatedBuilder}
  alias Spark.OptionsHelpers
  @behaviour Builder

  @type option ::
          encode_option
          | key_case_option
          | key_type_option
          | nest_option
          | ManyBuilder.option()
          | RelatedBuilder.option()

  @typedoc """
  Encode the result using the specified encoder.

  Smokestack will call `encode/1` on the module provided with the generated
  result (or results).  For example set `encode: Jason` or `encode: Poison`
  to encode the results as a JSON string.

  The module's encode function should return an ok/error tuple.
  """
  @type encode_option :: {:encode, module}

  @typedoc """
  Nest the result within the specified key in the output.
  """
  @type nest_option :: {:nest, String.t() | atom}

  @typedoc """
  Format the keys in the specified case. Defaults to `:snake`
  """
  @type key_case_option ::
          {:key_case,
           :camel
           | :constant
           | :dot
           | :header
           | :kebab
           | :name
           | :pascal
           | :path
           | {:path, separator :: String.t()}
           | :sentence
           | :snake
           | :title}

  @typedoc """
  Convert the keys into the specified type.  Defaults to `:atom`.
  """
  @type key_type_option :: {:key_type, :string | :atom}

  @type result :: %{required(String.t() | atom) => any}
  @type error :: any | ManyBuilder.error() | RelatedBuilder.error()

  @doc """
  Run the factory and return a map or list-of-maps of params.
  """
  @impl true
  @spec build(Factory.t(), [option]) :: {:ok, result} | {:error, error}
  def build(factory, options) do
    {count, options} = Keyword.pop(options, :count)
    do_build(factory, options, count)
  end

  @doc false
  @impl true
  @spec option_schema(Factory.t()) :: {:ok, OptionsHelpers.schema()} | {:error, error}
  def option_schema(factory) do
    with {:ok, schema0} <- RelatedBuilder.option_schema(factory),
         {:ok, schema1} <- ManyBuilder.option_schema(factory) do
      schema1 =
        Keyword.update!(schema1, :count, fn current ->
          current
          |> Keyword.update!(:type, &{:or, [&1, nil]})
          |> Keyword.put(:default, nil)
          |> Keyword.put(:required, false)
        end)

      schema =
        schema0
        |> Keyword.merge(schema1)
        |> Keyword.merge(
          encode: [
            type: {:or, [nil, :module]},
            required: false
          ],
          nest: [
            type: {:or, [:atom, :string]},
            required: false
          ],
          key_case: [
            type:
              {:or,
               [
                 {:tuple, [{:literal, :path}, :string]},
                 {:in,
                  [
                    :camel,
                    :constant,
                    :dot,
                    :header,
                    :kebab,
                    :name,
                    :pascal,
                    :path,
                    :sentence,
                    :snake,
                    :title
                  ]}
               ]},
            required: false,
            default: :snake
          ],
          key_type: [
            type: {:in, [:string, :atom]},
            required: false,
            default: :atom
          ]
        )

      {:ok, schema}
    end
  end

  defp do_build(factory, options, count) when is_integer(count) and count > 0 do
    {my_opts, their_opts} = split_options(options)
    their_opts = Keyword.put(their_opts, :count, count)

    with {:ok, attr_list} <- Builder.build(ManyBuilder, factory, their_opts) do
      attr_list
      |> convert_keys(my_opts)
      |> maybe_nest_result(my_opts[:nest])
      |> maybe_encode_result(my_opts[:encode])
    end
  end

  defp do_build(factory, options, _) do
    {my_opts, their_opts} = split_options(options)

    with {:ok, attrs} <- Builder.build(RelatedBuilder, factory, their_opts) do
      attrs
      |> convert_keys(my_opts)
      |> maybe_nest_result(my_opts[:nest])
      |> maybe_encode_result(my_opts[:encode])
    end
  end

  defp split_options(options), do: Keyword.split(options, ~w[encode key_case key_type nest]a)

  defp convert_keys(attr_list, options) when is_list(attr_list),
    do: Enum.map(attr_list, &convert_keys(&1, options))

  defp convert_keys(attrs, options) do
    Map.new(attrs, fn {key, value} ->
      key =
        key
        |> recase(options[:key_case] || :snake)
        |> cast(options[:key_type] || :atom)

      {key, value}
    end)
  end

  defp recase(key, style) when is_atom(key), do: key |> to_string() |> recase(style)
  defp recase(key, :camel), do: Recase.to_camel(key)
  defp recase(key, :constant), do: Recase.to_constant(key)
  defp recase(key, :dot), do: Recase.to_dot(key)
  defp recase(key, :header), do: Recase.to_header(key)
  defp recase(key, :kebab), do: Recase.to_kebab(key)
  defp recase(key, :name), do: Recase.to_name(key)
  defp recase(key, :pascal), do: Recase.to_pascal(key)
  defp recase(key, :path), do: Recase.to_path(key)
  defp recase(key, {:path, separator}), do: Recase.to_path(key, separator)
  defp recase(key, :sentence), do: Recase.to_sentence(key)
  defp recase(key, :snake), do: Recase.to_snake(key)
  defp recase(key, :title), do: Recase.to_title(key)

  defp cast(key, :atom), do: String.to_atom(key)
  defp cast(key, :string), do: key

  defp maybe_nest_result(result, nil), do: result
  defp maybe_nest_result(result, key) when is_atom(key) or is_binary(key), do: %{key => result}

  defp maybe_encode_result(result, nil), do: {:ok, result}
  defp maybe_encode_result(result, encoder) when is_atom(encoder), do: encoder.encode(result)
end
