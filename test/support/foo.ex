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

  def bar(a, b, c, d) do
    [a, b, c, d]
  end

  def bar(a, b, c, d, e) do
    [a, b, c, d, e]
  end

  def bar(a, b, c, d, e, f) do
    [a, b, c, d, e, f]
  end
end
