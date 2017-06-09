defmodule Coyote.Server do
  use GenServer

  @moduledoc """

  """

  @route_bridge Coyote.RouteBridge

  require Logger

  def start_link,
    do: GenServer.start_link(__MODULE__, [], name: Coyote)

  def init(_args),
    do: {:ok, []}

  def call(request) do
    GenServer.call(Coyote, request)

    receive do
      {:ok, _response} = response ->
        response
      {:error, _error} = error ->
        error
    end
  end

  def handle_info({:register, {mod, binary, file, func, topology, node}}, _state) do
    {:module, mod} = :code.load_binary(mod, file, binary)

    @route_bridge.update_routing_table(func.(), mod, node, topology)
    {:noreply, []}
  end

  def handle_cast({method, path, args, topology}, _state) do
    cast_route({method, path}, args, topology)
    {:noreply, []}
  end

  def handle_cast({method, path, args}, _state) do
    cast_route({method, path}, args, :default)
    {:noreply, []}
  end

  def handle_cast(req, _state) when is_tuple(req) do
    cast_route(req, [], :default)
    {:noreply, []}
  end

  def handle_call({method, path, args, topology}, from, _state),
    do: {:reply, call_route({method, path}, args, from, topology), []}

  def handle_call({method, path, args}, from, _state),
    do: {:reply, call_route({method, path}, args, from, :default), []}

  def handle_call(req, from, _state) when is_tuple(req),
    do: {:reply, call_route(req, [], from, :default), []}

  defp call_route(req, args, from, topology),
    do: Coyote.Relay.call({from, {req, args, topology}})

  defp cast_route(req, args, topology),
    do: Coyote.Relay.cast({req, args, topology})

end
