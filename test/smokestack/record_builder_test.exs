defmodule Smokestack.RecordBuilderTest do
  @moduledoc false
  use ExUnit.Case, async: true
  alias Smokestack.RecordBuilder

  describe "record/2..5" do
    test "it can insert a record" do
      assert {:ok, record} = RecordBuilder.build(Support.Factory, Support.Post)

      assert record.__struct__ == Support.Post
      assert record.__meta__.state == :loaded
      refute record.author.__struct__ == Support.Author
    end

    test "it can insert related records" do
      assert {:ok, record} =
               RecordBuilder.build(Support.Factory, Support.Post, %{}, :default, build: [:author])

      assert record.__struct__ == Support.Post
      assert record.__meta__.state == :loaded
      assert record.author.__struct__ == Support.Author
      assert record.author.__meta__.state == :loaded
    end

    test "it can perform a load on a record" do
      assert {:ok, record} =
               RecordBuilder.build(Support.Factory, Support.Post, %{}, :default,
                 load: :full_title
               )

      assert record.__struct__ == Support.Post
      assert record.full_title =~ ":"
    end
  end
end
