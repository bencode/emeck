defmodule EmeckTest do
  use ExUnit.Case
  import Emeck


  test "use mock" do
    with_meck String do
      expect String.length, fn s ->
        passthrough([s]) * 2
      end

      assert String.length("abc") == 6

      assert called String.length
      assert called String.length("abc")
      refute called String.length("abd")

      assert num_calls(String.length) == 1
      assert num_calls(String.length("abc")) == 1

      String.length("abd")
      assert called String.length("abd")
      assert num_calls(String.length) == 2
    end

    assert String.length("abc") == 3
  end
end
