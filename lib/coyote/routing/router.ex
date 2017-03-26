defmodule Coyote.Router do

  @moduledoc """

  """

  defmacro routes(do: routes) do
    quote do
      def __routes__() do
        unquote(routes)
      end
    end
  end

end
