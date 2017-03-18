defmodule Coyote.Topology.RouteTableTest do
  use ExUnit.Case

  alias Coyote.Topology.{RouteTable, Route}

  @meta_data %{topology: :test, route: nil}

  setup do
    Application.put_env(:coyote, :topology_events, self())

    RouteTable.start_link(@meta_data)

    route = %Route{module: __MODULE__, pid: self(), node: :node_name, route: {:GET, "/"}}

    on_exit fn ->
      Application.delete_env(:coyote, :topology_events)
    end

    {:ok, %{@meta_data | route: route}}
  end

  test "register a route in the topology and send monitoring notification", %{topology: topology, route: route} do
    register_routes(topology, route)
    assert_receive {:begin_monitor, ^route}
  end

  test "get all routes in a topology", %{topology: topology, route: route} do
    routes = [route, %Route{module: __MODULE__, pid: self(), node: :node_name, route: {:GET, "/hello"}}]

    assert [] == RouteTable.all(topology)

    register_routes(topology, routes)

    assert RouteTable.all(topology) == routes |> Enum.reverse
  end

  test "lookup routes by route key", %{topology: topology, route: route} do
    new_route = %Route{module: __MODULE__, pid: self(), node: :node_name, route: {:GET, "/hello"}}
    routes = [route, new_route]

    register_routes(topology, routes)

    assert RouteTable.lookup(topology, {:GET, "/"}) == {:ok, route}
    assert RouteTable.lookup(topology, {:GET, "/hello"}) == {:ok, new_route}
    assert RouteTable.lookup(topology, {:GET, "/not-found"}) == {:error, "No matching routes"}
  end

  test "delete routes by route key", %{topology: topology, route: route} do
    register_routes(topology, route)

    assert RouteTable.delete!(topology, {:GET, "/"}) == :ok
    assert RouteTable.lookup(topology, {:GET, "/"}) == {:error, "No matching routes"}
  end

  test "delete routes by process id", %{topology: topology, route: route} do
    new_route = %Route{module: __MODULE__, pid: self(), node: :node_name, route: {:GET, "/hello"}}
    routes = [route, new_route]
    register_routes(topology, routes)

    assert RouteTable.lookup(topology, {:GET, "/"}) == {:ok, route}
    assert RouteTable.lookup(topology, {:GET, "/hello"}) == {:ok, new_route}
    assert RouteTable.delete!(topology, route.pid) == :ok
    assert RouteTable.lookup(topology, {:GET, "/"}) == {:error, "No matching routes"}
    assert RouteTable.lookup(topology, {:GET, "/hello"}) == {:error, "No matching routes"}
  end

  test "delete routes by node", %{topology: topology, route: route} do
    new_route = %Route{module: __MODULE__, pid: self(), node: :node_name, route: {:GET, "/hello"}}
    routes = [route, new_route]
    register_routes(topology, routes)

    assert RouteTable.lookup(topology, {:GET, "/"}) == {:ok, route}
    assert RouteTable.lookup(topology, {:GET, "/hello"}) == {:ok, new_route}
    assert RouteTable.delete!(topology, route.node) == :ok
    assert RouteTable.lookup(topology, {:GET, "/"}) == {:error, "No matching routes"}
    assert RouteTable.lookup(topology, {:GET, "/hello"}) == {:error, "No matching routes"}
  end

  defp register_routes(topology, routes) do
    RouteTable.register(topology, routes)
    :timer.sleep(1)
  end

end
