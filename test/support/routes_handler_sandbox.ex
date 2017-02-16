defmodule Coyote.RouteHandler.Sandbox do

  alias Coyote.Topology.Route

  def start_link,
    do: GenServer.start_link(__MODULE__, [], name: :test_routes)

  def init(_args),
    do: {:ok, []}

  def update_routing_table(routes, mod, node) do
    GenServer.cast(:test_routes, {:update, {routes, mod, node}})
  end

  def find_route(req) do
    GenServer.call(:test_routes, {:find_route, req})
  end

  def handle_call({:find_route, {req, path}}, _from, state) do
    {:reply, Enum.find(state, &(&1.route == {req, path})), state}
  end

  def handle_cast({:update, {routes, mod, node}}, _state) do
    {:noreply, build_routes(routes, mod, node, [])}
  end

  defp build_routes([], _mod, _node, acc), do: acc
  defp build_routes([route|routes], mod, {pid, node}, acc) do
    build_routes(routes, mod, {pid, node}, [%Route{module: mod, route: route, pid: pid, node: node}|acc])
  end

end
