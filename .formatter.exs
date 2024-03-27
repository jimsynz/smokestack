spark_locals_without_parens = [
  attribute: 2,
  attribute: 3,
  domain: 1,
  factory: 1,
  factory: 2,
  factory: 3
]

[
  import_deps: [:ash, :spark],
  inputs: [
    "*.{ex,exs}",
    "{config,lib,test}/**/*.{ex,exs}"
  ],
  plugins: [Spark.Formatter],
  locals_without_parens: spark_locals_without_parens,
  export: [
    locals_without_parens: spark_locals_without_parens
  ]
]
