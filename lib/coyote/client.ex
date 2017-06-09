defmodule Coyote.Client do

  @moduledoc """

  The Coyote client module. Used to register application processes with Coyote
  servers.

  """

  defmacro __using__(opts) do
    quote do
      use GenServer

      import Coyote.Router, [only: [routes: 1]]

      @server unquote(opts[:leader]) || Coyote

      @name __MODULE__
      @nodes unquote(opts[:leader_nodes]) ||
        Application.get_env(:coyote, :leader_nodes, [:nonode@nohost])
      @topology unquote(opts[:topology]) ||
        Application.get_env(:coyote, :topology, :default)

      def start_link,
        do: GenServer.start_link(__MODULE__, [], name: @name)

      def init(_args) do
        send(self(), :register_routes)
        {:ok, []}
      end

      def handle_info(:register_routes, state) do
        Enum.each(@nodes, &register_routes/1)

        {:noreply, state}
      end

      def handle_info({:watch_leader, node}, state) do
        case Node.ping(node) do
          :pong ->
            register_routes(node)
          :pang ->
            send(self(), {:watch_leader, node})
        end
        {:noreply, state}
      end

      def handle_info({:DOWN, _ref, :process, {Coyote, node}, reason}, state) do
        send(self(), {:watch_leader, node})
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

      defp register_routes(node) do
        {mod, binary, file} = get_code()

        route_func = Application.get_env(:coyote, :routes, &mod.__routes__/0)

        case Node.ping(node) do
          :pong ->
            send({@server, node}, {:register, {mod, binary, file, route_func, @topology, {self(), Node.self()}}})

            Process.monitor({@server, node})
          :pang ->
            :ok
        end
      end

      defp get_code,
        do: :code.get_object_code(__MODULE__)

      def call(req, from, state),
        do: {:error, "No override provided for call/3"}

      def cast(req, state),
        do: {:error, "No override provided for cast/2"}

      def info(req, state),
        do: {:error, "No override provided for info/2"}

      defoverridable  [call: 3, cast: 2, info: 2]
    end
  end
end
