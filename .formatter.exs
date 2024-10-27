spark_locals_without_parens = [
  after_build: 1,
  after_build: 2,
  attribute: 2,
  attribute: 3,
  auto_build: 1,
  auto_load: 1,
  before_build: 1,
  before_build: 2,
  domain: 1,
  factory: 1,
  factory: 2,
  factory: 3,
  variant: 1
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
