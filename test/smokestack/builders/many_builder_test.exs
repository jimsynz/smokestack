defmodule Smokestack.ManyBuilderTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Smokestack.{Builder, Dsl.Info, ManyBuilder}
  alias Support.{Factory, Post}

  test "it can build a factory more than once" do
    {:ok, factory} = Info.factory(Factory, Post, :default)
    assert {:ok, results} = ManyBuilder.build(factory, count: 2)
    assert length(results) == 2
    assert Enum.all?(results, &(byte_size(&1.title) > 0))
  end

  test "it errors when asked to build less than one instance" do
    {:ok, factory} = Info.factory(Factory, Post, :default)
    assert {:error, reason} = ManyBuilder.build(factory, count: 0)
    assert Exception.message(reason) =~ ~r/positive integer/i
  end
end
