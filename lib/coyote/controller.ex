defmodule Coyote.Handler do
  defmacro __using__(_opts) do
    quote do
      use GenServer

      def child_spec,
        do: Supervisor.Spec.worker(__MODULE__, [], restart: :transient)

      def start_link,
        do: GenServer.start_link(__MODULE__, [])

      def handle_call({method, path, params}, _from, req) when method in [:get, :post, :put, :patch, :delete, :option] do
        response = handle({method, path}, params)

        {:reply, response, req}
      end

      def render(output, status \\ 200, headers \\ [{"content-type", "text/html"}]),
        do: {status, headers, output}

      def handle(method, bindings)
      defoverridable [handle: 2]
    end
  end
end
