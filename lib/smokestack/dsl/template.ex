defmodule Smokestack.Dsl.Template do
  @moduledoc """
  Templates which assist in the generation of values.œ
  """

  alias Smokestack.Template

  @type mapper :: nil | (any -> any)
  @type element :: any

  defguardp is_mapper(fun) when is_nil(fun) or is_function(fun, 1)

  @doc """
  Randomly select between a list of options.
  """
  @spec choose(Enumerable.t(element), mapper) :: Template.t()
  def choose(options, mapper \\ nil) when is_mapper(mapper),
    do: %Template.Choose{options: options, mapper: mapper}

  @doc """
  Select a constant value
  """
  @spec constant(element, mapper) :: Template.t()
  def constant(value, mapper \\ nil) when is_mapper(mapper),
    do: %Template.Constant{value: value, mapper: mapper}

  @doc """
  Cycle sequentially between a list of options.
  """
  @spec cycle(Enumerable.t(element), mapper) :: Template.t()
  def cycle(options, mapper \\ nil) when is_mapper(mapper),
    do: %Template.Cycle{options: options, mapper: mapper}

  @doc """
  Generate sequential values.
  """
  @spec sequence(mapper, [{:start, number} | {:step, number}]) :: Template.t()
  def sequence(mapper \\ nil, sequence_options \\ []) when is_mapper(mapper) do
    sequence_options
    |> Map.new()
    |> Map.put(:mapper, mapper)
    |> Enum.reject(&is_nil(elem(&1, 1)))
    |> then(&struct(Template.Sequence, &1))
  end

  @doc """
  Call a generator a number of times.
  """
  @spec n_times(pos_integer | Range.t(pos_integer, pos_integer), Template.t(), mapper) ::
          Template.t()
  def n_times(n, generator, mapper \\ nil)

  def n_times(n, generator, mapper) when is_integer(n) and n > 0 and is_mapper(mapper),
    do: %Template.NTimes{n: n, generator: generator, mapper: mapper}

  def n_times(range, generator, mapper)
      when is_struct(range, Range) and is_integer(range.first) and is_integer(range.last) and
             is_integer(range.step),
      do: %Template.NTimes{n: range, generator: generator, mapper: mapper}
end
