defmodule SpannerEctoTest do
  use ExUnit.Case
  doctest SpannerEcto

  test "greets the world" do
    assert SpannerEcto.hello() == :world
  end
end
