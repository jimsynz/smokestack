defmodule Smokestack.RelatedBuilderTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Smokestack.{Builder, Dsl.Info, RelatedBuilder}
  alias Support.{Factory, Post}

  test "it can build attributes from directly related factories" do
    {:ok, factory} = Info.factory(Factory, Post, :default)
    assert {:ok, attrs} = Builder.build(RelatedBuilder, factory, build: :author)
    assert byte_size(attrs[:author][:name]) > 0
  end

  test "it can build attributes from indirectly related factories" do
    {:ok, factory} = Info.factory(Factory, Post, :default)
    assert {:ok, attrs} = Builder.build(RelatedBuilder, factory, build: [author: :posts])
    assert [post] = attrs[:author][:posts]
    assert byte_size(post[:title]) > 0
  end
end
