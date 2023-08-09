defmodule SmokestackTest do
  use ExUnit.Case
  doctest Smokestack

  test "greets the world" do
    assert Smokestack.hello() == :world
  end
end
