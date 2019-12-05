defmodule Emeck.Helper do
  @moduledoc """
  utility functions can be used in test.
  """

  defmacro expect({{:., _, [m, f]}, _, []}, proxy) do
    quote do
      :meck.expect(unquote(m), unquote(f), unquote(proxy))
    end
  end

  defmacro passthrough do
    quote do
      :meck.passthrough([])
    end
  end

  defmacro passthrough(list) when is_list(list) do
    quote do
      :meck.passthrough(unquote(list))
    end
  end
  defmacro passthrough(a) do
    quote do
      passthrough([unquote(a)])
    end
  end
  defmacro passthrough(a, b) do
    quote do
      passthrough([unquote(a), unquote(b)])
    end
  end
  defmacro passthrough(a, b, c) do
    quote do
      passthrough([unquote(a), unquote(b), unquote(c)])
    end
  end
  defmacro passthrough(a, b, c, d) do
    quote do
      passthrough([unquote(a), unquote(b), unquote(c), unquote(d)])
    end
  end
  defmacro passthrough(a, b, c, d, e) do
    quote do
      passthrough([unquote(a), unquote(b), unquote(c), unquote(d), unquote(e)])
    end
  end

  # called String.length
  # called String.length("foo")
  # called &String.length/1
  defmacro called(expr) do
    {m, f, a} = mfa(expr)
    quote do
      :meck.called(unquote(m), unquote(f), unquote(a))
    end
  end

  defmacro call_count(expr) do
    {m, f, a} = mfa(expr)
    quote do
      :meck.num_calls(unquote(m), unquote(f), unquote(a))
    end
  end

  defmacro reset_call(mod) do
    quote do
      :meck.reset(unquote(mod))
    end
  end

  defmacro calls(expr) do
    {m, f, a} = mfa(expr)
    quote bind_quoted: [m: m, f: f, a: a] do
      list = :meck.history(m)
      Emeck.Util.filter_calls(list, f, a)
    end
  end

  defmacro call_args(expr) do
    quote do
      {args, _} = last_call(unquote(expr))
      args
    end
  end

  defmacro call_return(expr) do
    quote do
      {_, result} = last_call(unquote(expr))
      result
    end
  end

  defmacro first_call(expr) do
    quote do
      unquote(expr) |> calls |> List.first
    end
  end

  defmacro last_call(expr) do
    quote do
      unquote(expr) |> calls |> List.last
    end
  end

  defp mfa({{:., _, [mod, fun]}, _, []}) do
    {mod, fun, :_}
  end
  defp mfa({{:., _, [mod, fun]}, _, args}) do
    {mod, fun, args}
  end
  defp mfa({:&, _, [{:/, _, [{{:., _, [mod, fun]}, _, []}, arity]}]}) do
    {mod, fun, arity}
  end
end
