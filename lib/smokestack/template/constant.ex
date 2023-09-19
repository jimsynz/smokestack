defmodule Smokestack.Template.Constant do
  @moduledoc false
  defstruct value: nil, mapper: nil

  @type t :: %__MODULE__{value: any, mapper: Smokestack.Template.mapper()}

  defimpl Smokestack.Template do
    def init(constant), do: constant

    def generate(constant, _, _) when is_function(constant.mapper, 1),
      do: constant.mapper(constant.value)

    def generate(constant, _, _),
      do: constant.value
  end
end
