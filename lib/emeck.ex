defmodule Emeck do
  @moduledoc """
  Mock modules for unit test
  """

  defmacro with_meck(mods, do: test) do
    mods = is_list(mods) && mods || [mods]
    quote do
      import Emeck.Helper
      mods = unquote(mods)

      Enum.map(mods, fn
        {mod, opts} -> :meck.new(mod, opts)
        mod -> :meck.new(mod, [:passthrough])
      end)

      try do
        unquote(test)
      after
        Enum.map(mods, fn
          {mod, _} -> :meck.unload(mod)
          mod -> :meck.unload(mod)
        end)
      end
    end
  end

  def install(mod, opts \\ [:passthrough]) do
    :meck.new(mod, opts)
  end

  def uninstall(mod) do
    :meck.unload(mod)
  end

  defmodule Util do
    @moduledoc false

    def filter_calls(calls, f, a) do
      calls
      |> Enum.filter(fn {_pis, {_mod, fun, args}, _result} ->
        cond do
          a == :_ -> fun == f
          is_number(a) -> fun == f && length(args) == a
          is_list(a) -> fun == f && args == a
        end
      end)
      |> Enum.map(fn {_pid, {_mod, _fun, args}, result} ->
        {args, result}
      end)
    end
  end
end
