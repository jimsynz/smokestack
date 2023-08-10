defmodule Smokestack.Template.Cycle do
  @moduledoc false
  defstruct options: [], count: 0, mapper: nil, agent: nil

  @type t :: %__MODULE__{
          options: Enumerable.t(any),
          count: non_neg_integer,
          mapper: Smokestack.Template.mapper(),
          agent: nil | pid
        }

  defimpl Smokestack.Template do
    def init(cycle) do
      {:ok, pid} = Agent.start_link(fn -> 0 end)

      {options, count} =
        Enum.reduce(cycle.options, {[], 0}, fn option, {options, count} ->
          {[option | options], count + 1}
        end)

      %{cycle | options: Enum.reverse(options), count: count, agent: pid}
    end

    def generate(cycle, _record, _options) when is_function(cycle.mapper, 1) do
      count = Agent.get_and_update(cycle.agent, &{&1, &1 + 1})
      index = rem(count, cycle.count)

      cycle.options
      |> Enum.at(index)
      |> cycle.mapper.()
    end

    def generate(cycle, _record, _options) do
      count = Agent.get_and_update(cycle.agent, &{&1, &1 + 1})
      index = rem(count, cycle.count)

      cycle.options
      |> Enum.at(index)
    end
  end
end
