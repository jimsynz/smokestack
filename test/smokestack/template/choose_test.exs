defmodule Smokestack.Template.ChooseTest do
  @moduledoc false
  use ExUnit.Case, async: true
  alias Smokestack.{Template, Template.Choose}

  describe "Smokestack.Template.init/1" do
    test "it doesn't do anything" do
      choose = %Choose{options: [1, 2, 3], mapper: &Function.identity/1}

      assert ^choose = Template.init(choose)
    end
  end

  describe "Smokestack.Template.generate/3" do
    test "it chooses a random option" do
      value =
        %Choose{options: [1, 2, 3]}
        |> Template.generate(nil, nil)

      assert value in [1, 2, 3]
    end

    test "it can map the chosen value" do
      value =
        %Choose{options: [1, 2, 3], mapper: &(&1 * 3)}
        |> Template.generate(nil, nil)

      assert value in [3, 6, 9]
    end
  end
end
