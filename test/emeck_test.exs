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

      # call not stubed method
      assert String.split("foo bar") == ["foo", "bar"]
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

      Foo.bar
      Foo.bar("a")
      Foo.bar("a", "b")
      Foo.bar("a", "b")
      Foo.bar("c", "d")

      assert called Foo.bar
      assert call_count(Foo.bar) == 5

      assert called Foo.bar("a")
      assert call_count(Foo.bar("a")) == 1

      assert call_count(Foo.bar("a", "b")) == 2

      assert called Foo.bar("a", "b")
      assert call_count(Foo.bar("c", "d")) == 1

      assert called &Foo.bar/2
      assert call_count(&Foo.bar/0) == 1
      assert call_count(&Foo.bar/2) == 3

      refute called &Foo.bar/3
    end
  end


  test "reset call" do
    with_meck String do
      expect String.length, &passthrough(&1)

      assert String.length("abc") == 3
      assert called String.length

      reset_call String
      refute called String.length
    end
  end


  test "calls history" do
    with_meck String do
      expect String.length, &passthrough(&1)

      String.length "a"
      String.length "ab"
      String.length "abc"

      list = calls String.length
      assert list == [
        {["a"], 1},
        {["ab"], 2},
        {["abc"], 3}
      ]

      assert call_args(String.length) == ["abc"]
      assert call_return(String.length) == 3

      assert first_call(String.length) == {["a"] ,1}
      assert last_call(String.length) == {["abc"] ,3}
    end
  end


  test "calls history arity and arguments" do
    with_meck Foo do
      expect Foo.bar, &passthrough(&1)
      expect Foo.bar, &passthrough(&1, &2)

      Foo.bar("a")
      Foo.bar("a", "b")

      assert call_return(Foo.bar("a")) == "a"
      assert call_return(Foo.bar("a", "b")) == ["a", "b"]

      assert call_args(&Foo.bar/1) == ["a"]
      assert call_args(&Foo.bar/2) == ["a", "b"]
      assert call_args(Foo.bar) == ["a", "b"]  # last
    end
  end


  test "mock httppotion" do
    with_meck HTTPoison do
      expect HTTPoison.get!, fn url ->
        %{body: "hi: " <> url}
      end

      %{body: body} = HTTPoison.get!("https://github.com")
      assert body == "hi: https://github.com"

      assert called HTTPoison.get!
      assert call_count(HTTPoison.get!) == 1

      assert call_args(HTTPoison.get!) == ["https://github.com"]
      assert call_return(HTTPoison.get!) == %{body: "hi: https://github.com"}
    end
  end
end
