defmodule Smokestack.Dsl.Verifier do
  @moduledoc false
  alias Ash.Resource.Info
  alias Smokestack.{Dsl.Attribute, Dsl.Factory, Template}
  alias Spark.{Dsl, Dsl.Verifier, Error.DslError}
  use Verifier

  @doc false
  @impl true
  @spec verify(Dsl.t()) :: :ok | {:error, DslError.t()}
  def verify(dsl_state) do
    error_info = %{
      module: Verifier.get_persisted(dsl_state, :module),
      path: [:smokestack],
      dsl_state: dsl_state
    }

    factories =
      dsl_state
      |> Verifier.get_entities([:smokestack])
      |> Enum.filter(&is_struct(&1, Factory))

    with :ok <- verify_unique_factories(factories, error_info) do
      Enum.reduce_while(factories, :ok, fn factory, :ok ->
        case verify_factory(factory, error_info) do
          :ok -> {:cont, :ok}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)
    end
  end

  defp verify_unique_factories(factories, error_info) do
    factories
    |> Enum.map(&{&1.resource, &1.variant})
    |> Enum.frequencies()
    |> Enum.reject(&(elem(&1, 1) == 1))
    |> Enum.map(&elem(&1, 0))
    |> case do
      [] ->
        :ok

      duplicates ->
        message =
          duplicates
          |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
          |> Enum.map(fn {resource, variants} -> {resource, Enum.uniq(variants)} end)
          |> Enum.sort_by(&elem(&1, 0))
          |> Enum.reduce(
            "Multiple factories defined for the following:",
            fn {resource, variants}, message ->
              variants =
                variants
                |> Enum.sort()
                |> Enum.map_join(", ", &"`#{&1}`")

              message <>
                "\n  - `#{inspect(resource)}`: #{variants}"
            end
          )

        {:error,
         DslError.exception(
           module: error_info.module,
           path: Enum.reverse(error_info.path),
           message: message
         )}
    end
  end

  defp verify_factory(factory, error_info) do
    error_info =
      Map.merge(error_info, %{resource: factory.resource, path: [:factory | error_info.path]})

    with :ok <- verify_unique_attributes(factory, error_info),
         :ok <- verify_auto_build(factory, error_info),
         :ok <- verify_auto_load(factory, error_info) do
      factory
      |> Map.get(:attributes, [])
      |> Enum.filter(&is_struct(&1, Attribute))
      |> Enum.reduce_while(:ok, fn attribute, :ok ->
        case verify_attribute(attribute, error_info) do
          :ok -> {:cont, :ok}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)
    end
  end

  defp verify_unique_attributes(factory, error_info) do
    factory
    |> Map.get(:attributes, {})
    |> Enum.filter(&is_struct(&1, Attribute))
    |> Enum.map(& &1.name)
    |> Enum.frequencies()
    |> Enum.reject(&(elem(&1, 1) == 1))
    |> Enum.map(&elem(&1, 0))
    |> case do
      [] ->
        :ok

      duplicates ->
        duplicates =
          duplicates
          |> Enum.uniq()
          |> Enum.sort()
          |> Enum.map_join(", ", &"`#{&1}`")

        {:error,
         DslError.exception(
           module: error_info.module,
           path: Enum.reverse(error_info.path),
           message:
             "Duplicate attributes for factory `#{inspect(factory.resource)}`/`#{factory.variant}`: " <>
               duplicates
         )}
    end
  end

  defp verify_attribute(attribute, error_info) do
    error_info = %{error_info | path: [:attribute | error_info.path]}

    with :ok <- verify_attribute_in_resource(attribute, error_info) do
      verify_attribute_generator(attribute, error_info)
    end
  end

  defp verify_attribute_in_resource(attribute, error_info) do
    case Info.attribute(error_info.resource, attribute.name) do
      nil ->
        {:error,
         DslError.exception(
           module: error_info.module,
           path: Enum.reverse(error_info.path),
           message:
             "No attribute named `#{inspect(attribute.name)}` defined on the `#{inspect(error_info.resource)}` resource."
         )}

      _ ->
        :ok
    end
  end

  defp verify_attribute_generator(attribute, _error_info)
       when is_function(attribute.generator, 0),
       do: :ok

  defp verify_attribute_generator(attribute, _error_info)
       when is_function(attribute.generator, 1),
       do: :ok

  defp verify_attribute_generator(attribute, _error_info)
       when is_function(attribute.generator, 2),
       do: :ok

  defp verify_attribute_generator(attribute, error_info) when is_struct(attribute.generator) do
    case Template.impl_for(attribute.generator) do
      nil ->
        {:error,
         DslError.exception(
           module: error_info.module,
           path: Enum.reverse(error_info.path),
           message:
             "Protocol `Smokestack.Template` not implemented for `#{inspect(attribute.generator.__struct__)}`."
         )}

      _ ->
        :ok
    end
  end

  defp verify_attribute_generator(%{generator: {m, f, a}}, error_info)
       when {m, f, a}
       when is_atom(m) and is_atom(f) and is_list(a) do
    min_arity = length(a)
    max_arity = min_arity + 2

    m.info(:functions)
    |> Enum.any?(fn {name, arity} ->
      name == f && arity >= min_arity && arity <= max_arity
    end)
    |> case do
      true ->
        :ok

      false ->
        {:error,
         DslError.exception(
           module: error_info.module,
           path: Enum.reverse(error_info.path),
           message: "No exported function matching `#{inspect(m)}.#{f}/#{min_arity}..#{max_arity}"
         )}
    end
  end

  defp verify_auto_build(factory, error_info) do
    error_info = %{error_info | path: [:auto_build | error_info.path]}

    Enum.reduce_while(factory.auto_build, :ok, fn relationship, :ok ->
      error_info = %{error_info | path: [relationship | error_info.path]}

      with {:ok, relationship} <- verify_relationship(factory.resource, relationship, error_info),
           :ok <- verify_factory_exists(relationship.destination, error_info) do
        {:cont, :ok}
      else
        {:error, error} -> {:halt, {:error, error}}
      end
    end)
  end

  defp verify_relationship(resource, relationship, error_info) do
    case Info.relationship(resource, relationship) do
      nil ->
        {:error,
         DslError.exception(
           module: error_info.module,
           path: Enum.reverse(error_info.path),
           message:
             "The resource `#{inspect(resource)}` has no relationship named `#{inspect(relationship)}`."
         )}

      relationship ->
        {:ok, relationship}
    end
  end

  defp verify_factory_exists(resource, error_info) do
    factory_exists? =
      error_info.dsl_state
      |> Verifier.get_entities([:smokestack])
      |> Enum.any?(&(is_struct(&1, Factory) && &1.resource == resource))

    if factory_exists? do
      :ok
    else
      {:error,
       DslError.exception(
         module: error_info.module,
         path: Enum.reverse(error_info.path),
         message: "No factories defined for resource `#{inspect(resource)}`."
       )}
    end
  end

  defp verify_auto_load(factory, error_info) do
    error_info = %{error_info | path: [:auto_load | error_info.path]}

    Enum.reduce_while(factory.auto_load, :ok, fn load, :ok ->
      error_info = %{error_info | path: [load | error_info.path]}

      with nil <- Info.calculation(factory.resource, load),
           nil <- Info.aggregate(factory.resource, load),
           nil <- Info.relationship(factory.resource, load) do
        {:halt,
         {:error,
          DslError.exception(
            module: error_info.module,
            path: Enum.reverse(error_info.path),
            message:
              "Expected an aggregate, calculation or relationship named `#{inspect(load)}` on resource `#{inspect(factory.resource)}`"
          )}}
      else
        _ -> {:cont, :ok}
      end
    end)
  end
end
