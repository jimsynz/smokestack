defmodule Smokestack.Dsl do
  alias Spark.Dsl.{Extension, Section}
  alias Smokestack.Dsl.{Factory, Transformer, Verifier}

  @section %Section{
    name: :smokestack,
    top_level?: true,
    entities: Factory.__entities__(),
    schema: [
      domain: [
        type: {:behaviour, Ash.Domain},
        required: false,
        doc: "The default Ash Domain to use when evaluating loads"
      ]
    ]
  }

  @moduledoc """
  The DSL definition for the Smokestack DSL.

  <!--- ash-hq-hide-start --> <!--- -->

  ## DSL Documentation

  ### Index

  #{Extension.doc_index([@section])}

  ### Docs

  #{Extension.doc([@section])}

  <!--- ash-hq-hide-stop --> <!--- -->
  """

  use Extension,
    sections: [@section],
    transformers: [Transformer],
    verifiers: [Verifier]
end
