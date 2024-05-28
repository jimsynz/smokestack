defmodule Smokestack.RecordBuilderTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Smokestack.{Builder, Dsl.Info, RecordBuilder}
  alias Support.{Author, Factory, Post}

  test "it can build a single record" do
    {:ok, factory} = Info.factory(Factory, Post, :default)
    assert {:ok, record} = RecordBuilder.build(factory, [])
    assert is_struct(record, Post)
    assert record.__meta__.state == :loaded
  end

  test "it can build multiple records" do
    {:ok, factory} = Info.factory(Factory, Post, :default)
    assert {:ok, records} = RecordBuilder.build(factory, count: 2)
    assert length(records) == 2
    assert Enum.all?(records, &(is_struct(&1, Post) && &1.__meta__.state == :loaded))
  end

  test "it can build directly related records" do
    {:ok, factory} = Info.factory(Factory, Post, :default)
    assert {:ok, record} = RecordBuilder.build(factory, build: :author)
    assert is_struct(record.author, Author)
    assert record.author.__meta__.state == :loaded
  end

  test "it can build indirectly related records" do
    {:ok, factory} = Info.factory(Factory, Post, :default)
    assert {:ok, record} = RecordBuilder.build(factory, build: [author: :posts])
    assert [%Post{} = post] = record.author.posts
    assert post.__meta__.state == :loaded
  end

  test "it can load calculations" do
    {:ok, factory} = Info.factory(Factory, Post, :default)
    assert {:ok, record} = RecordBuilder.build(factory, load: :full_title)
    assert record.full_title == record.title <> ": " <> record.sub_title
  end

  test "it can load aggregates" do
    {:ok, factory} = Info.factory(Factory, Post, :default)

    assert {:ok, record} =
             RecordBuilder.build(factory,
               load: [author: :count_of_posts],
               build: [author: :posts]
             )

    assert record.author.count_of_posts == 2
  end

  test "it can load relationships" do
    {:ok, factory} = Info.factory(Factory, Post, :default)

    assert {:ok, record} =
             RecordBuilder.build(factory, build: :author, load: [author: :posts])

    assert [post] = record.author.posts
    assert post.id == record.id
  end
end
