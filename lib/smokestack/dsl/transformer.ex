defmodule Smokestack.Dsl.Transformer do
  @moduledoc false

  alias Spark.{Dsl, Dsl.Transformer, Error.DslError}
  use Transformer

  @doc false
  @spec transform(Dsl.t()) :: {:ok, Dsl.t()} | {:error, DslError.t()}
  def transform(dsl_state) do
    {:ok, dsl_state}
  end
end
