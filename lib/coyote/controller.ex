defmodule Coyote.Controller do
  defmacro __using__(_opts) do
    quote do
      use GenServer

      def child_spec,
        do: Supervisor.Spec.worker(__MODULE__, [], restart: :transient)

      def start_link,
        do: GenServer.start_link(__MODULE__, [])

      def handle_call(method, _from, req) when method in [:get, :post, :put, :patch, :delete, :option] do
        response = handle(method, [])
        {:reply, response, req}
      end

      def handle(method, bindings)
      defoverridable [handle: 2]
    end
  end
end
