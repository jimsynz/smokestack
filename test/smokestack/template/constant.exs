defmodule Smokestack.Template.ChooseTest do
  @moduledoc false
  use ExUnit.Case, async: true
  alias Smokestack.{Template, Template.Constant}

  describe "Smokestack.Template.init/1" do
    test "it doesn't do anything" do
      constant = %Constant{value: 1, mapper: &Function.identity/1}

      assert ^constant = Template.init(constant)
    end
  end

  describe "Smokestack.Template.generate/3" do
    test "it returns the same value" do
      value =
        %Constant{value: 1}
        |> Template.generate(nil, nil)

      assert value == 1
    end

    test "it can map the chosen value" do
      value =
        %Constant{value: 1, mapper: &(&1 * 3)}
        |> Template.generate(nil, nil)

      assert value == 3
    end
  end
end
