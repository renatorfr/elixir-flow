defmodule ElixirFlowTest do
  use ExUnit.Case
  doctest ElixirFlow

  test "greets the world" do
    assert ElixirFlow.hello() == :world
  end
end
