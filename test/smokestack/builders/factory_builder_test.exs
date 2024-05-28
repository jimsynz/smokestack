defmodule Smokestack.FactoryBuilderTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Smokestack.{Builder, Dsl.Info, FactoryBuilder}
  alias Support.{Factory, Post}

  test "it can build attributes from a factory" do
    {:ok, factory} = Info.factory(Factory, Post, :default)
    assert {:ok, attrs} = FactoryBuilder.build(factory, [])
    assert byte_size(attrs[:title]) > 0
  end

  test "it allows attributes to be overridden" do
    {:ok, factory} = Info.factory(Factory, Post, :default)

    assert {:ok, %{title: "wat"}} = FactoryBuilder.build(factory, attrs: %{title: "wat"})
  end
end
