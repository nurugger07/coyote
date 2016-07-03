defmodule Coyote.Router do

  def collect_routes,
    do: modules |> mod_routes

  def modules do
    Mix.Project.compile_path
    |> Path.join("*.beam")
    |> Path.wildcard
    |> Enum.map(&beam_to_module/1)
  end

  defp beam_to_module(path) do
    path
    |> Path.basename(".beam")
    |> String.to_atom
  end

  def mod_routes([], acc), do: acc
  def mod_routes([module|rest], acc \\ []) do
    case module.__info__(:functions) |> Keyword.has_key?(:__routes__) do
      true ->
        acc = module.__routes__ ++ acc
      _ ->
        []
    end
    mod_routes(rest, acc)
  end

  defmacro routes(do: routes) do
    quote do
      def __routes__() do
        unquote(routes) |> IO.inspect
      end
    end
  end

  defmacro __using__(_opts) do
    quote location: :keep do

      require unquote(__MODULE__)

      import unquote(__MODULE__)

    end
  end

end
