defmodule Smokestack.Template.CycleTest do
  @moduledoc false
  use ExUnit.Case, async: true
  alias Smokestack.{Template, Template.Cycle}

  describe "Smokestack.Template.init/1" do
    test "it starts an agent" do
      cycle = Template.init(%Cycle{options: [:a, :b, :c]})
      assert is_pid(cycle.agent)
    end
  end

  describe "Smokestack.Template.generate/3" do
    test "it cycles through it's options" do
      cycle = Template.init(%Cycle{options: [:a, :b, :c]})

      assert :a = Template.generate(cycle, nil, nil)
      assert :b = Template.generate(cycle, nil, nil)
      assert :c = Template.generate(cycle, nil, nil)
      assert :a = Template.generate(cycle, nil, nil)
      assert :b = Template.generate(cycle, nil, nil)
      assert :c = Template.generate(cycle, nil, nil)
    end

    test "it can map it's options" do
      cycle = Template.init(%Cycle{options: ~w[a b c], mapper: &String.upcase/1})

      assert "A" = Template.generate(cycle, nil, nil)
      assert "B" = Template.generate(cycle, nil, nil)
      assert "C" = Template.generate(cycle, nil, nil)
      assert "A" = Template.generate(cycle, nil, nil)
      assert "B" = Template.generate(cycle, nil, nil)
      assert "C" = Template.generate(cycle, nil, nil)
    end
  end
end
