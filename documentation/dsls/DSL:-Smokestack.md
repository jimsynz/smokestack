<!--
This file was generated by Spark. Do not edit it by hand.
-->
# DSL: Smokestack.Dsl

The DSL definition for the Smokestack DSL.

<!--- ash-hq-hide-start --> <!--- -->

## DSL Documentation

### Index

  * smokestack
    * factory
      * after_build
      * attribute
      * before_build

### Docs

## smokestack



 * [factory](#module-factory)
   * after_build
   * attribute
   * before_build





---

* `:domain` (module that adopts `Ash.Domain`) - The default Ash Domain to use when evaluating loads



### factory

Define factories for a resource

    * after_build
    * attribute
    * before_build



* `:domain` (module that adopts `Ash.Domain`) - The Ash Domain to use when evaluating loads

* `:resource` (module that adopts `Ash.Resource`) - Required. An Ash Resource

* `:variant` (`t:atom/0`) - The name of a factory variant The default value is `:default`.

* `:auto_build` (one or a list of `t:atom/0`) - A list of relationships that should always be built when building this factory The default value is `[]`.

* `:auto_load` - An Ash "load statement" to always apply when building this factory The default value is `[]`.



##### after_build

Modify the record after building.

Allows you to provide a function which can modify the built record before returning.

These hooks are only applied when building records and not parameters.






* `:hook` (mfa or function of arity 1) - Required. A function which returns an updated record






##### attribute







* `:name` (`t:atom/0`) - Required. The name of the target attribute

* `:generator` - Required. A function which can generate an appropriate value for the attribute.œ






##### before_build

Modify the attributes before building.

Allows you to provide a function which can modify the the attributes before building.






* `:hook` (mfa or function of arity 1) - Required. A function which returns an updated record










<!--- ash-hq-hide-stop --> <!--- -->


## smokestack


### Nested DSLs
 * [factory](#smokestack-factory)
   * after_build
   * attribute
   * before_build





### Options

| Name | Type | Default | Docs |
|------|------|---------|------|
| [`domain`](#smokestack-domain){: #smokestack-domain } | `module` |  | The default Ash Domain to use when evaluating loads |



## smokestack.factory
```elixir
factory resource, variant \\ :default
```


Define factories for a resource

### Nested DSLs
 * [after_build](#smokestack-factory-after_build)
 * [attribute](#smokestack-factory-attribute)
 * [before_build](#smokestack-factory-before_build)




### Arguments

| Name | Type | Default | Docs |
|------|------|---------|------|
| [`resource`](#smokestack-factory-resource){: #smokestack-factory-resource .spark-required} | `module` |  | An Ash Resource |
| [`variant`](#smokestack-factory-variant){: #smokestack-factory-variant } | `atom` | `:default` | The name of a factory variant |
### Options

| Name | Type | Default | Docs |
|------|------|---------|------|
| [`domain`](#smokestack-factory-domain){: #smokestack-factory-domain } | `module` |  | The Ash Domain to use when evaluating loads |
| [`auto_build`](#smokestack-factory-auto_build){: #smokestack-factory-auto_build } | `atom \| list(atom)` | `[]` | A list of relationships that should always be built when building this factory |
| [`auto_load`](#smokestack-factory-auto_load){: #smokestack-factory-auto_load } | `atom \| keyword \| list(atom \| keyword)` | `[]` | An Ash "load statement" to always apply when building this factory |


## smokestack.factory.after_build
```elixir
after_build hook
```


Modify the record after building.

Allows you to provide a function which can modify the built record before returning.

These hooks are only applied when building records and not parameters.






### Arguments

| Name | Type | Default | Docs |
|------|------|---------|------|
| [`hook`](#smokestack-factory-after_build-hook){: #smokestack-factory-after_build-hook .spark-required} | `(any -> any) \| mfa` |  | A function which returns an updated record |






### Introspection

Target: `Smokestack.Dsl.AfterBuild`

## smokestack.factory.attribute
```elixir
attribute name, generator
```








### Arguments

| Name | Type | Default | Docs |
|------|------|---------|------|
| [`name`](#smokestack-factory-attribute-name){: #smokestack-factory-attribute-name .spark-required} | `atom` |  | The name of the target attribute |
| [`generator`](#smokestack-factory-attribute-generator){: #smokestack-factory-attribute-generator .spark-required} | `(-> any) \| mfa \| (any -> any) \| mfa \| (any, any -> any) \| mfa \| Smokestack.Template.Choose \| Smokestack.Template.Constant \| Smokestack.Template.Cycle \| Smokestack.Template.NTimes \| Smokestack.Template.Sequence` |  | A function which can generate an appropriate value for the attribute.œ |






### Introspection

Target: `Smokestack.Dsl.Attribute`

## smokestack.factory.before_build
```elixir
before_build hook
```


Modify the attributes before building.

Allows you to provide a function which can modify the the attributes before building.






### Arguments

| Name | Type | Default | Docs |
|------|------|---------|------|
| [`hook`](#smokestack-factory-before_build-hook){: #smokestack-factory-before_build-hook .spark-required} | `(any -> any) \| mfa` |  | A function which returns an updated record |






### Introspection

Target: `Smokestack.Dsl.BeforeBuild`




### Introspection

Target: `Smokestack.Dsl.Factory`





<style type="text/css">.spark-required::after { content: "*"; color: red !important; }</style>
