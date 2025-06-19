defmodule QuickFactoryTest do
  use ExUnit.Case
  doctest QuickFactory

  test "greets the world" do
    assert QuickFactory.hello() == :world
  end
end
