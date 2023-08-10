defmodule Smokestack.Template.Choose do
  @moduledoc false
  defstruct options: [], mapper: nil

  @type t :: %__MODULE__{options: Enumerable.t(any), mapper: Smokestack.Template.mapper()}

  defimpl Smokestack.Template do
    def init(choose), do: choose

    def generate(choose, _, _) when is_function(choose.mapper, 1),
      do: choose.options |> Enum.random() |> choose.mapper.()

    def generate(choose, _, _), do: Enum.random(choose.options)
  end
end
