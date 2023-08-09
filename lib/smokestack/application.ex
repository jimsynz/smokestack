defmodule Smokestack.Application do
  @moduledoc false

  use Application

  @impl true
  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_type, _args) do
    []
    |> Supervisor.start_link(strategy: :one_for_one, name: Smokestack.Supervisor)
  end
end
