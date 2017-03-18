defmodule Coyote.RouteHandler.Sandbox do

  alias Coyote.Topology.Route

  def start_link,
    do: GenServer.start_link(__MODULE__, [], name: :test_routes)

  def init(_args),
    do: {:ok, []}

  def update_routing_table(routes, mod, node, topology \\ :default) do
    GenServer.cast(:test_routes, {:update, {routes, topology, mod, node}})
  end

  def find_route(req, topology \\ :default) do
    GenServer.call(:test_routes, {:find_route, req, topology})
  end

  def handle_call({:find_route, {req, path}, _topology}, _from, state) do
    response = case Enum.find(state, &(&1.route == {req, path})) do
                 nil ->
                   {:error, "No matching routes"}
                 route ->
                   {:ok, route}
               end
    {:reply, response, state}
  end

  def handle_cast({:update, {routes, _topology, mod, node}}, _state) do
    {:noreply, build_routes(routes, mod, node, [])}
  end

  defp build_routes([], _mod, _node, acc), do: acc
  defp build_routes([route|routes], mod, {pid, node}, acc) do
    build_routes(routes, mod, {pid, node}, [%Route{module: mod, route: route, pid: pid, node: node}|acc])
  end

end
