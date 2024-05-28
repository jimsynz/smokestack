defmodule Smokestack.RelatedBuilderTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Smokestack.{Builder, Dsl.Info, RecordBuilder, RelatedBuilder}
  alias Support.{Author, Factory, Post}

  test "it can build attributes from directly related factories" do
    {:ok, factory} = Info.factory(Factory, Post, :default)
    assert {:ok, attrs} = RelatedBuilder.build(factory, build: :author)
    assert byte_size(attrs[:author][:name]) > 0
  end

  test "it can build attributes from indirectly related factories" do
    {:ok, factory} = Info.factory(Factory, Post, :default)
    assert {:ok, attrs} = RelatedBuilder.build(factory, build: [author: :posts])
    assert [post] = attrs[:author][:posts]
    assert byte_size(post[:title]) > 0
  end

  test "it can attach directly related records" do
    {:ok, factory} = Info.factory(Factory, Post, :default)
    {:ok, author} = RecordBuilder.build(Info.factory!(Factory, Author, :default), [])
    {:ok, attrs} = RelatedBuilder.build(factory, relate: [author: author])
    assert attrs[:author] == author
  end
end
