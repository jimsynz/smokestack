defmodule Support.Api do
  @moduledoc false
  use Ash.Api, validate_config_inclusion?: false

  resources do
    allow_unregistered? true
  end
end
