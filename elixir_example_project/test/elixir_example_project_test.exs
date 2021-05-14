defmodule ElixirExampleProjectTest do
  use ExUnit.Case
  doctest ElixirExampleProject

  test "greets the world" do
    assert ElixirExampleProject.hello() == :world
  end
end
