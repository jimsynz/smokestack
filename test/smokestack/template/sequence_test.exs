defmodule Smokestack.Template.SequenceTest do
  @moduledoc false
  use ExUnit.Case, async: true
  alias Smokestack.{Template, Template.Sequence}

  describe "Smokestack.Template.init/1" do
    test "it starts an agent" do
      sequence =
        %Sequence{}
        |> Template.init()

      assert is_pid(sequence.agent)
    end
  end

  describe "Smokestack.Template.generate/3" do
    test "it generates sequential values" do
      sequence =
        %Sequence{}
        |> Template.init()

      assert 1 = Template.generate(sequence, nil, nil)
      assert 2 = Template.generate(sequence, nil, nil)
      assert 3 = Template.generate(sequence, nil, nil)
      assert 4 = Template.generate(sequence, nil, nil)
    end
  end
end
