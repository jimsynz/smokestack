defprotocol Smokestack.Template do
  @moduledoc """
  A protocol for generating values from templates.
  """

  @type mapper :: nil | (any -> any)

  @doc """
  Initialise the template, if required.
  """
  @spec init(t) :: t
  def init(template)

  @doc """
  Generate a value from the template.
  """
  @spec generate(t, map, keyword) :: any
  def generate(template, record, options)
end

defimpl Smokestack.Template, for: Function do
  def init(template), do: template

  def generate(fun, _record, _options) when is_function(fun, 0), do: fun.()
  def generate(fun, record, _options) when is_function(fun, 1), do: fun.(record)
  def generate(fun, record, options) when is_function(fun, 2), do: fun.(record, options)
end
