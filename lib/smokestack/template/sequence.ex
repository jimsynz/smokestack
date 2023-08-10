defmodule Smokestack.Template.Sequence do
  @moduledoc false
  defstruct mapper: nil, start: 1, step: 1, agent: nil

  @type t :: %__MODULE__{
          mapper: Smokestack.Template.mapper(),
          start: number,
          step: number,
          agent: nil | pid
        }

  defimpl Smokestack.Template do
    def init(sequence) do
      {:ok, pid} = Agent.start_link(fn -> sequence.start end)
      %{sequence | agent: pid}
    end

    def generate(sequence, _record, _options) when is_function(sequence.mapper, 1) do
      count = Agent.get_and_update(sequence.agent, &{&1, &1 + sequence.step})
      sequence.mapper.(count)
    end

    def generate(sequence, _record, _options),
      do: Agent.get_and_update(sequence.agent, &{&1, &1 + sequence.step})
  end
end
