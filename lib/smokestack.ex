defmodule Smokestack do
  alias Spark.{Dsl, Dsl.Extension}

  @moduledoc """

  <!--- ash-hq-hide-start --> <!--- -->

  ## DSL Documentation

  ### Index

  #{Extension.doc_index(Smokestack.Dsl.sections())}

  ### Docs

  #{Extension.doc(Smokestack.Dsl.sections())}

  <!--- ash-hq-hide-stop --> <!--- -->
  """

  use Dsl, default_extensions: [extensions: [Smokestack.Dsl]]

  @type t :: module
end
