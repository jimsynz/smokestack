defmodule Smokestack.ParamBuilderTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Smokestack.ParamBuilder
  alias Support.{Author, Factory, Post}

  describe "build/2..5" do
    test "it builds params" do
      assert {:ok, params} = ParamBuilder.build(Factory, Post)
      assert params |> Map.keys() |> Enum.sort() == ~w[body sub_title tags title]a
      assert params.body
      assert Enum.all?(params.tags, &is_binary/1)
      assert params.title
    end

    test "it honours the `as: :list` option" do
      assert {:ok, params} = ParamBuilder.build(Factory, Post, %{}, :default, as: :list)
      assert is_list(params)
      assert params[:body]
      assert Enum.all?(params[:tags], &is_binary/1)
      assert params[:title]
    end

    test "it honours the `keys: :string` option" do
      assert {:ok, params} = ParamBuilder.build(Factory, Post, %{}, :default, keys: :string)
      assert params["body"]
      assert Enum.all?(params["tags"], &is_binary/1)
      assert params["title"]
    end

    test "it honours the `keys: :dasherise` option" do
      assert {:ok, params} = ParamBuilder.build(Factory, Post, %{}, :default, keys: :dasherise)
      assert params["sub-title"]
    end

    test "it honours the `build` option for single relationships" do
      assert {:ok, params} = ParamBuilder.build(Factory, Post, %{}, :default, build: :author)
      assert params.author.name
      assert params.author.email
    end

    test "it honours the `build` option for many relationships" do
      assert {:ok, params} = ParamBuilder.build(Factory, Author, %{}, :default, build: :posts)
      assert [post] = params.posts
      assert post.title
    end

    test "it honours nested `build` options" do
      assert {:ok, params} =
               ParamBuilder.build(Factory, Author, %{}, :default, build: [posts: [:author]])

      assert [post] = params.posts
      assert post.author.name
      assert params.name != post.author.name
    end
  end
end
