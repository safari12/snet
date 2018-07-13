defmodule SnetTest do
  use ExUnit.Case
  doctest Snet

  test "greets the world" do
    assert Snet.hello() == :world
  end
end
