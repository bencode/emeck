defmodule EmeckTest do
  use ExUnit.Case
  import Emeck


  test "simple mock" do
    with_meck String do
      spy String.length, fn s ->
        passthrough([s]) * 2
      end

      assert String.length("abc") == 6

      assert called String.length
      assert called String.length("abc")
      refute called String.length("abd")

      assert call_count(String.length) == 1
      assert call_count(String.length("abc")) == 1

      String.length("abd")
      assert called String.length("abd")
      assert call_count(String.length) == 2
    end

    assert String.length("abc") == 3
  end


  test "multiple mods" do
    with_meck [String] do
      assert 1 == 1
    end
  end
end
