defmodule Coyote.Server do
  use GenServer

  alias Coyote.Topology.Route

  @bridge Coyote.RouteBridge

  require Logger

  def start_link,
    do: GenServer.start_link(__MODULE__, [], name: Coyote)

  def init(_args),
    do: {:ok, []}

  def handle_info({:register, {mod, binary, file, func, topology, node}}, _state) do
    {:module, mod} = :code.load_binary(mod, file, binary)

    route_bridge.update_routing_table(func.(), mod, node, topology)
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

  def handle_call({method, path, args, topology}, _from, _state),
    do: {:reply, call_route({method, path}, args, topology), []}

  def handle_call({method, path, args}, _from, _state),
    do: {:reply, call_route({method, path}, args, :default), []}

  def handle_call(req, _from, _state) when is_tuple(req),
    do: {:reply, call_route(req, [], :default), []}

  defp call_route(req, args, topology) do
    case route_bridge.find_route(req, topology) do
      {:ok, %Route{pid: pid, route: {method, path}}} ->
        case GenServer.call(pid, {method, path, args}) do
          {:error, _message} ->
            {:error, "Routing error"}
          {:ok, response} = reply ->
            reply
          response ->
            {:ok, response}
        end
      {:error, "No matching routes"} = error ->
        error
      nil ->
        {:error, "No matching route"}
    end
  end

  defp cast_route(req, args, topology) do
    case route_bridge.find_route(req, topology) do
      {:ok, %Route{pid: pid, route: {method, path}}} ->
        GenServer.cast(pid, {method, path, args})
      _ ->
        {:error, "No matching route"}
    end
  end

  defp route_bridge,
    do: Application.get_env(:coyote, :route_bridge, Coyote.RouteBridge)
end
