defmodule Smokestack.BuilderTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Smokestack.Builder
  alias Support.{Factory, Post}

  describe "params/2..5" do
    test "it builds params" do
      assert {:ok, params} = Builder.params(Factory, Post)
      assert params |> Map.keys() |> Enum.sort() == ~w[body tags title]a
      assert is_binary(params.body)
      assert Enum.all?(params.tags, &is_binary/1)
      assert is_binary(params.title)
    end
  end
end
