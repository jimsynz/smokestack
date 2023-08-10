defmodule Smokestack.Builder do
  @moduledoc """
  Handles the building of parameters and records.
  """

  alias Ash.Resource
  alias Smokestack.{Dsl.Attribute, Dsl.Info, Template}

  @param_option_defaults [keys: :atom, as: :map]

  @typedoc "Options that can be passed to `params/4`."
  @type param_options :: [param_keys_option | param_as_option]

  @typedoc "Key type in the result. Defaults to `#{inspect(@param_option_defaults[:keys])}`."
  @type param_keys_option :: {:keys, :atom | :string | :dasherise}

  @typedoc "Result type. Defaults to `#{inspect(@param_option_defaults[:as])}`"
  @type param_as_option :: {:as, :map | :list}

  @type param_result ::
          %{required(String.t()) => any}
          | %{required(atom) => any}
          | [{String.t(), any}]
          | [{atom, any}]

  @doc """
  Build parameters for a resource with a factory.
  """
  @spec params(Smokestack.t(), Resource.t(), atom, param_options) ::
          {:ok, param_result} | {:error, any}
  def params(factory_module, resource, variant \\ :default, overrides \\ %{}, options \\ [])
      when is_atom(factory_module) and is_atom(resource) and is_atom(variant) and is_list(options) do
    with {:ok, factory} <- get_factory(factory_module, resource, variant),
         {:ok, params} <- build_params(factory, overrides, options) do
      params =
        params
        |> maybe_stringify_keys(options)
        |> maybe_dasherise_keys(options)
        |> maybe_listify_result(options)

      {:ok, params}
    end
  end

  @doc "Raising version of `params/2..5`."
  @spec params!(Smokestack.t(), Resource.t(), atom, param_options) :: param_result | no_return
  def params!(factory_module, resource, variant \\ :default, overrides \\ %{}, options \\ []) do
    case params(factory_module, resource, variant, overrides, options) do
      {:ok, params} -> params
      {:error, reason} -> raise reason
    end
  end

  defp get_factory(factory_module, resource, variant) do
    with :error <- Info.factory(factory_module, resource, variant) do
      {:error,
       ArgumentError.exception(
         message: "Factory for `#{inspect(resource)}` variant `#{inspect(variant)}` not found."
       )}
    end
  end

  defp build_params(factory, overrides, options) do
    factory
    |> Map.get(:attributes, [])
    |> Enum.filter(&is_struct(&1, Attribute))
    |> Enum.reduce({:ok, %{}}, fn attr, {:ok, attrs} ->
      case Map.fetch(overrides, attr.name) do
        {:ok, override} ->
          {:ok, Map.put(attrs, attr.name, override)}

        :error ->
          value = Template.generate(attr.generator, attrs, options)
          {:ok, Map.put(attrs, attr.name, value)}
      end
    end)
  end

  defp maybe_stringify_keys(attrs, options) do
    if Keyword.get(options, :keys, @param_option_defaults[:keys]) == :string do
      Map.new(fn {key, value} -> {Atom.to_string(key), value} end)
    else
      attrs
    end
  end

  defp maybe_dasherise_keys(attrs, options) do
    if Keyword.get(options, :keys, @param_option_defaults[:keys]) == :dasherise do
      Map.new(fn {key, value} ->
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
