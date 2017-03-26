defmodule Coyote.Client do

  @moduledoc """

  """

  defmacro __using__(opts) do
    quote do
      use GenServer

      import Coyote.Router, [only: [routes: 1]]

      @server unquote(opts[:leader]) || Coyote

      @name __MODULE__
      @nodes Application.get_env(:coyote, :leader_node, [:nonode@nohost])
      @topology Application.get_env(:coyote, :topology, :default)

      def start_link,
        do: GenServer.start_link(__MODULE__, [], name: @name)

      def init(_args) do
        send(self, :register_routes)
        {:ok, []}
      end

      def handle_info(:register_routes, state) do
        {mod, binary, file} = get_code()

        route_func = Application.get_env(:coyote, :routes, &mod.__routes__/0)

        Enum.each(@nodes, fn(node) ->
          send({@server, node}, {:register, {mod, binary, file, route_func, @topology, {self(), Node.self()}}})

          Process.monitor({@server, node})
        end)

        {:noreply, state}
      end

      def handle_info(:watch_leader, state) do
        case Node.ping(@node) do
          :pong ->
            send(self, :register_routes)
          :pang ->
            send(self, :watch_leader)
        end
        {:noreply, state}
      end

      def handle_info({:DOWN, _ref, :process, {Coyote, node}, _reason}, state) do
        send(self, :watch_leader)
        {:noreply, state}
      end

      def handle_call(req, from, state) when is_tuple(req) do
        try do
          call(req, from, state)
        rescue
          FunctionClauseError ->
            {:reply, {:error, "Undefined FunctionClauseError"}, state}
        end
      end

      def handle_cast(req, state) when is_tuple(req) do
        try do
          cast(req, state)
        rescue
          FunctionClauseError ->
            {:noreply, state}
        end
      end

      def handle_info(req, state) when is_tuple(req) do
        try do
          cast(req, state)
        rescue
          FunctionClauseError ->
            {:noreply, state}
        end
      end

      defp get_code,
        do: :code.get_object_code(__MODULE__)

      def call(req, from, state),
        do: {:error, "No override provided for call/3"}

      def cast(req, state) do
        IO.inspect req
        {:error, "No override provided for cast/2"}
      end

      def info(req, state),
        do: {:error, "No override provided for info/2"}

      defoverridable  [call: 3, cast: 2, info: 2]
    end
  end
end
