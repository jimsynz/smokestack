defmodule Mix.Tasks.Smokestack.Install do
  @moduledoc "Installs smokestack. Should be run with `mix igniter.install smokestack`."
  @shortdoc @moduledoc
  alias Igniter.{Code.Common, Code.Module, Mix.Task, Project.Formatter}
  require Common
  use Task

  def igniter(igniter, _argv) do
    factory = Module.module_name("Factory")

    igniter
    |> Formatter.import_dep(:smokestack)
    |> Igniter.compose_task("smokestack.gen.factory_module", [
      inspect(factory),
      "--ignore-if-exists"
    ])
  end
end
