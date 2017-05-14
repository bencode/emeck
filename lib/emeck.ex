defmodule Emeck do
  @moduledoc """
  Mock modules for unit test
  """


  defmacro with_meck(mods, do: test) do
    quote do
      import Emeck.Helper
      mods =
        case unquote(mods) do
          list when is_list(list) -> list
          atom when is_atom(atom) -> [atom]
        end

      Enum.map(mods, fn
        {mod, opts} -> :meck.new(mod, opts)
        mod -> :meck.new(mod)
      end)

      try do
        unquote(test)
      after
        Enum.map(mods, &:meck.unload/1)
      end
    end
  end


  defmodule Helper do
    # expect(Foo.bar, fn arg, ... -> ... end)
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


    defmacro called(call) do
      {m, f, a} = mfa(call)
      quote do
        :meck.called(unquote(m), unquote(f), unquote(a))
      end
    end


    defmacro call_count(call) do
      {m, f, a} = mfa(call)
      quote do
        :meck.num_calls(unquote(m), unquote(f), unquote(a))
      end
    end


    defmacro call_args do
    end

    defmacro call_return do
    end

    defmacro calls do
    end

    defmacro first_call do
    end

    defmacro last_call do
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
end
