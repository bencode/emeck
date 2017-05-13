defmodule EmeckTest do
  use ExUnit.Case
  import Emeck


  test "simple mock" do
    with_meck String do
      expect String.length, fn s ->
        passthrough(s) * 2
      end

      assert String.length("foo") == 6

      assert called String.length
      assert called String.length("foo")
      refute called String.length("bar")

      assert call_count(String.length) == 1
      assert call_count(String.length("foo")) == 1

      String.length("bar")
      assert called String.length("bar")
      assert call_count(String.length) == 2
    end

    assert String.length("foo") == 3
  end


  test "muti modules" do
    with_meck [String, Path] do
      expect String.length, &passthrough(&1)
      expect Path.join, &passthrough(&1, &2)

      assert String.length("foo") == 3
      assert called String.length

      assert Path.join("foo", "bar") == "foo/bar"
    end

    with_meck String do
      expect String.length, &(passthrough(&1) + 1)
      assert String.length("foo") == 4
    end
    assert String.length("foo") == 3
  end


  defmodule Foo do
    def bar(a), do: a
    def bar(a, b), do: [a, b]
    def bar(a, b, c), do: [a, b, c]
    def bar(a, b, c, d), do: [a, b, c, d]
    def bar(a, b, c, d, e), do: [a, b, c, d, e]
  end

  test "passthrough with diffent arity" do
    with_meck Foo do
      expect Foo.bar, &passthrough(&1)
      expect Foo.bar, &passthrough(&1, &2)
      expect Foo.bar, &passthrough(&1, &2, &3)
      expect Foo.bar, &passthrough(&1, &2, &3, &4)
      expect Foo.bar, &passthrough(&1, &2, &3, &4, &5)

      assert Foo.bar("a") == "a"
      assert Foo.bar("a", "b") == ["a", "b"]
      assert Foo.bar("a", "b", "c") == ["a", "b", "c"]
      assert Foo.bar("a", "b", "c", "d") == ["a", "b", "c", "d"]
      assert Foo.bar("a", "b", "c", "d", "e") == ["a", "b", "c", "d", "e"]
    end
  end
end
