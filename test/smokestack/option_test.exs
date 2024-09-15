defmodule Smokestack.OptionTest do
  @moduledoc false
  use ExUnit.Case, async: true

  use Support.Factory
  alias Support.{Author, Post}

  describe "no options" do
    test "a record can be generated directly from the factory" do
      assert {:ok, author} = insert(Author)
      assert is_binary(author.id)
      assert is_binary(author.name)
      assert is_binary(to_string(author.email))
    end
  end

  describe "attrs" do
    test "a record can be generated from the factory with some attributes overridden" do
      assert {:ok, author} = insert(Author, attrs: %{name: "J.M. Dillard"})
      assert author.name == "J.M. Dillard"
    end
  end

  describe "count" do
    test "many records can be generated from the factory" do
      assert {:ok, authors} = insert(Author, count: 3)
      assert length(authors) == 3
    end
  end

  describe "build" do
    test "it can build directly related records from the factory" do
      assert {:ok, author} = insert(Author, build: [:posts])
      assert [%Post{}] = author.posts
    end

    test "it can build indirectly directly related records from the factory" do
      assert {:ok, post} = insert(Post, build: [author: :posts])
      assert %Author{} = post.author
      assert [other_post] = post.author.posts
      assert other_post.id != post.id
    end
  end

  describe "load" do
    test "it can load related records at build time" do
      assert {:ok, author} = insert(Author)
      assert {:ok, post} = insert(Post, attrs: %{author_id: author.id}, load: [:author])
      assert post.author.id == author.id
    end

    test "it can load calculations at build time" do
      assert {:ok, post} = insert(Post, load: [:full_title])
      assert post.full_title == "#{post.title}: #{post.sub_title}"
    end

    test "it can load aggregates at build time" do
      assert {:ok, post} = insert(Post, build: [:author], load: [author: :count_of_posts])
      assert post.author.count_of_posts == 1
    end
  end

  describe "relate" do
    test "it can relate records at build time" do
      assert {:ok, author} = insert(Author)
      assert {:ok, post} = insert(Post, relate: [author: author])
      assert post.author.id == author.id
    end
  end

  describe "variant" do
    test "it can select a variant at build time" do
      assert {:ok, author} = insert(Author, variant: :trek)
      assert to_string(author.email) =~ ~r/\.(starfleet|rebellion)$/
    end
  end

  test "it validates all options" do
    assert {:error, error} = insert(Author, sss: 2)
    message = Exception.message(error)
    assert message =~ ~r/unknown option/
  end
end
