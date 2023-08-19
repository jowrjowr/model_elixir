defmodule ModelElixirTest do
  use ExUnit.Case
  doctest ModelElixir

  test "greets the world" do
    assert ModelElixir.hello() == :world
  end
end
