# Emeck

[![Build Status](https://travis-ci.org/bencode/emeck.svg?branch=master)](https://travis-ci.org/bencode/emeck)
[![Coverage Status](https://coveralls.io/repos/bencode/emeck/badge.svg?branch=master)](https://coveralls.io/r/bencode/emeck?branch=master)
[![hex.pm version](https://img.shields.io/hexpm/v/emeck.svg)](https://hex.pm/packages/emeck)
[![Deps Status](https://beta.hexfaktor.org/badge/all/github/bencode/emeck.svg)](https://beta.hexfaktor.org/github/bencode/emeck)


A Mocking library for Elixir language. It's implemented based on [meck](https://github.com/eproxus/meck)


## Installation

Add emeck to your `mix.exs` dependencies:

```elixir
def deps do
  [{:emeck, "~> 1.0"}]
end
```

## Examples


### Simple Useage


```elixir
defmodule MyTest do
  use ExUnit.Case
  import Emeck

  test "simple mock" do
    %{body: body} = HTTPoison.get!("https://github.com")
    assert body =~ "<html"

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
```
