defmodule EmeckTest do
  use ExUnit.Case
  import Emeck


  test "simple mock" do
    with_meck String do
      expect String.length, fn s ->
        passthrough(s) * 2
      end

      assert String.length("foo") == 6
      assert String.length("foo bar") == 14

      assert called String.length
      assert called String.length("foo")
      refute called String.length("bar")

      assert call_count(String.length)  == 2
      assert call_count(String.length("foo")) == 1
      assert call_count(String.length("foo bar")) == 1
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


  test "passthrough with different arity" do
    assert Foo.bar == "hello"
    assert Foo.bar("a") == "a"

    with_meck Foo do
      expect Foo.bar, fn -> passthrough() end
      expect Foo.bar, &passthrough(&1)
      expect Foo.bar, &passthrough(&1, &2)
      expect Foo.bar, &passthrough(&1, &2, &3)
      expect Foo.bar, &passthrough(&1, &2, &3, &4)
      expect Foo.bar, &passthrough(&1, &2, &3, &4, &5)
      # more arity should passed as list
      expect Foo.bar, &passthrough([&1, &2, &3, &4, &5, &6])

      assert Foo.bar() == "hello"
      assert Foo.bar("a") == "a"
      assert Foo.bar("a", "b") == ["a", "b"]
      assert Foo.bar("a", "b", "c") == ["a", "b", "c"]
      assert Foo.bar("a", "b", "c", "d") == ["a", "b", "c", "d"]
      assert Foo.bar("a", "b", "c", "d", "e") == ["a", "b", "c", "d", "e"]
      assert Foo.bar("a", "b", "c", "d", "e","f") == ["a", "b", "c", "d", "e", "f"]

      assert called Foo.bar
      assert call_count(Foo.bar) == 7
      assert call_count(Foo.bar("a", "b")) == 1
    end
  end


  test "call and call_count with different arity" do
    with_meck Foo do
      expect Foo.bar, fn -> :ok end
      expect Foo.bar, &passthrough(&1)
      expect Foo.bar, &passthrough(&1, &2)
      expect Foo.bar, &passthrough(&1, &2, &3)

      Foo.bar
      Foo.bar("a")
      Foo.bar("a", "b")
      Foo.bar("c", "d")

      assert called Foo.bar
      assert call_count(Foo.bar) == 4

      assert called Foo.bar("a")
      assert call_count(Foo.bar("a")) == 1

      assert called Foo.bar("a", "b")
      assert call_count(Foo.bar("c", "d")) == 1

      assert call_count(&Foo.bar/0) == 1
      assert call_count(&Foo.bar/2) == 2
    end
  end
end
