defmodule Smokestack.ParamBuilderTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Smokestack.{Dsl.Info, ParamBuilder}
  alias Support.{Factory, Post}

  describe "build/2..5" do
    test "it builds params" do
      assert {:ok, factory} = Info.factory(Factory, Post, :default)
      assert {:ok, params} = ParamBuilder.build(factory, [])
      assert params |> Map.keys() |> Enum.sort() == ~w[body sub_title tags title]a
      assert params.body
      assert Enum.all?(params.tags, &is_binary/1)
      assert params.title
    end

    test "it honours the `:encode` option" do
      assert {:ok, factory} = Info.factory(Factory, Post, :default)
      assert {:ok, params} = ParamBuilder.build(factory, encode: Jason)
      assert is_binary(params)
      assert {:ok, params} = Jason.decode(params)
      assert params["body"]
      assert Enum.all?(params["tags"], &is_binary/1)
      assert params["title"]
    end

    test "it honours the `:key_case` option" do
      assert {:ok, factory} = Info.factory(Factory, Post, :default)
      assert {:ok, params} = ParamBuilder.build(factory, key_case: :kebab)
      assert params[:"sub-title"]
    end

    test "it honours the `:key_type` option" do
      assert {:ok, factory} = Info.factory(Factory, Post, :default)
      assert {:ok, params} = ParamBuilder.build(factory, key_type: :string)
      assert params["title"]
    end

    test "it honours the `:nest` option" do
      assert {:ok, factory} = Info.factory(Factory, Post, :default)
      assert {:ok, params} = ParamBuilder.build(factory, nest: :data)
      assert params[:data][:title]
    end

    test "it honours all options at once" do
      assert {:ok, factory} = Info.factory(Factory, Post, :default)

      assert {:ok, params} =
               ParamBuilder.build(factory, encode: Jason, key_case: :camel, nest: :data)

      assert {:ok, params} = Jason.decode(params)
      assert params["data"]["subTitle"]
    end
  end
end
