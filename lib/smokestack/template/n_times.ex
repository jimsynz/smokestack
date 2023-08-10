defmodule Smokestack.Template.NTimes do
  @moduledoc false
  defstruct n: 1, generator: nil, mapper: nil

  @type t :: %__MODULE__{
          n: non_neg_integer,
          generator: Smokestack.Template.t(),
          mapper: Smokestack.Template.mapper()
        }

  defimpl Smokestack.Template do
    def init(ntimes), do: ntimes

    def generate(ntimes, record, options) when is_integer(ntimes.n) do
      0..ntimes.n
      |> Enum.map(fn _ ->
        ntimes.generator
        |> Smokestack.Template.generate(record, options)
        |> maybe_map(ntimes.mapper)
      end)
    end

    def generate(ntimes, record, options) when is_struct(ntimes.n, Range) do
      ntimes.n
      |> Enum.random()
      |> then(&(0..&1))
      |> Enum.map(fn _ ->
        ntimes.generator
        |> Smokestack.Template.generate(record, options)
        |> maybe_map(ntimes.mapper)
      end)
    end

    defp maybe_map(value, fun) when is_function(fun, 1), do: fun.(value)
    defp maybe_map(value, _), do: value
  end
end
