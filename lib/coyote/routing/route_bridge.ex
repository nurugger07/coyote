defmodule Coyote.RouteBridge do

  @moduledoc """

  """

  @route_table Application.get_env(:coyote, :route_table, Coyote.Topology.RouteTable)
  @events Application.get_env(:coyote, :route_events, Coyote.Route.Events)

  alias Coyote.Topology.Route

  def update_routing_table(routes, mod, node, topology \\ :default) do
    routes = compile_routes(routes, mod, node)
    {:ok, _pid} = Coyote.Topology.Supervisor.new_topology(topology)

    @route_table.register(topology, routes)

    send(@events, {:routes_registered, topology})
  end

  def find_route(route, topology \\ :default),
    do: @route_table.lookup(topology, route)

  defp compile_routes(routes, mod, node, acc \\ [])

  defp compile_routes([], _mod, _node, acc),
    do: acc

  defp compile_routes([route|routes], mod, {pid, node}, acc),
    do: compile_routes(routes, mod, {pid, node}, [%Route{module: mod, pid: pid, node: node, route: route}|acc])

end
