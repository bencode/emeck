defmodule Emeck do
  @moduledoc """
  Mock modules for unit test
  """


  defmacro with_meck(mods, do: test) do
    quote do
      import Emeck.Helper

      mods = unquote(mods)
      mods = is_list(mods) && mods || [mods]
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
    defmacro expect({{:., _, [m, f]}, _, []}, proxy) do
      quote do
        :meck.expect(unquote(m), unquote(f), unquote(proxy))
      end
    end


    defmacro passthrough do
      quote do
        :meck.passthrough
      end
    end

    defmacro passthrough(list) when is_list(list) do
      quote do
        :meck.passthrough(unquote(list))
      end
    end


    defmacro called({{:., _, [m, f]}, _, []}) do
      quote do
        :meck.called(unquote(m), unquote(f), :_)
      end
    end

    defmacro called({{:., _, [m, f]}, _, args}) do
      quote do
        :meck.called(unquote(m), unquote(f), unquote(args))
      end
    end


    defmacro num_calls({{:., _, [m, f]}, _, []}) do
      quote do
        :meck.num_calls(unquote(m), unquote(f), :_)
      end
    end

    defmacro num_calls({{:., _, [m, f]}, _, args}) do
      quote do
        :meck.num_calls(unquote(m), unquote(f), unquote(args))
      end
    end
  end
end
