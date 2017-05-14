# Emeck

[![Build Status](https://travis-ci.org/bencode/emeck.svg?branch=master)](https://travis-ci.org/bencode/emeck)
[![Coverage Status](https://coveralls.io/repos/bencode/emeck/badge.svg?branch=master)](https://coveralls.io/r/bencode/emeck?branch=master)
[![hex.pm version](https://img.shields.io/hexpm/v/emeck.svg)](https://hex.pm/packages/emeck)
[![Deps Status](https://beta.hexfaktor.org/badge/all/github/bencode/emeck.svg)](https://beta.hexfaktor.org/github/bencode/emeck)


A Mocking library for Elixir language. It's implemented based on [meck](https://github.com/eproxus/meck).


## Installation

Add emeck to your `mix.exs` dependencies:

```elixir
def deps do
  [{:emeck, "~> 1.0"}]
end
```

## Examples


## simple usage

```elixir
defmodule MyTest do
  use ExUnit.Case
  import Emeck

  test "simple mock" do
    with_meck HTTPoison do
      expect HTTPoison.get!, fn url ->
        %{body: "hi: " <> url}
      end

      %{body: body} = HTTPoison.get!("https://github.com")
      assert body == "hi: https://github.com"

      assert called HTTPoison.get!
      assert call_count(HTTPoison.get!) == 1
    end
  end
end
```


## passthrough

Dispatch to original functions.

```elixir
  test "passthrough" do
    with_meck String do
      expect String.length, fn s -> passthrough(s) * 2 end
    end

    assert String.length("foo") == 6
  end
```


## muti modules

```elixir
  test "muti modules" do
    with_meck [String, Path] do
      expect String.length, &passthrough(&1)
      expect Path.join, &passthrough(&1, &2)

      String.length("foo")
      assert called String.length

      Path.join("foo", "bar")
      assert called Path.join
    end
  end
end
```


## distinguish calls

```elixir
defmodule Foo do
  def bar do
    "hello"
  end

  def bar(a) do
    a
  end

  def bar(a, b) do
    [a, b]
  end

  def bar(a, b, c) do
    [a, b, c]
  end
end
```

```elixir
  test "distinguish diffent arity and arguments calls" do
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

      assert call_count(Foo.bar("a")) == 1
      assert call_count(Foo.bar("a", "b")) == 2
      assert call_count(Foo.bar("c", "d")) == 1

      assert called &Foo.bar/0
      assert call_count(&Foo.bar/2) == 3

      refute called &Foo.bar/3
    end
  end
```

## calls history

```elixir
  test "calls history" do
    with_meck String do
      expect String.length, &passthrough(&1)

      String.length "a"
      String.length "ab"
      String.length "abc"

      assert calls(String.length) == [
        {["a"], 1}   # {args, return}
        {["ab"], 2}
        {["abc"], 3}
      ]

      assert first_call(Striing.length) == {["a"], 1}
      assert last_call(Striing.length) == {["abc"], 3}

      # last call args and return
      assert call_args(String.length) == ["abc"]
      assert call_return(String.legnth) == 3
    end
  end
```

## reset calls

```elixir
  with_meck String do
    expect String.length, &passthrough(&1)

    assert String.length("abc") == 3
    assert called String.length

    reset_call String
    refute called String.length
  end
```


## License

MIT
