defmodule EmeckTest do
  use ExUnit.Case
  import Emeck


  test "simple mock" do
    with_meck String do
      expect String.length, fn s ->
        passthrough([s]) * 2
      end

      assert String.length("abc") == 6

      assert called String.length
      assert called String.length("abc")
      assert not called String.length("abd")
    end
  end
end
