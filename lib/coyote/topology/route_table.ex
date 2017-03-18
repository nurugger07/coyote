defmodule Coyote.Topology.RouteTable do
  use GenServer

  @moduledoc """
  Store route information for connected applications
  """

  def start_link(%{topology: topology} = opts),
    do: GenServer.start_link(__MODULE__, opts, name: route_table_name(topology))

  def init(opts) do
    send(self, :configure)
    {:ok, opts}
  end

  def register(topology, routes) do
    topology
    |> route_table_name()
    |> send({:register, routes})
  end

  def all(topology) do
    topology
    |> route_table_name()
    |> GenServer.call(:all)
  end

  def lookup(topology, route) do
    topology
    |> route_table_name()
    |> GenServer.call({:lookup, route})
  end

  def delete!(topology, key) do
    topology
    |> route_table_name()
    |> send({:delete!, key})
    :ok
  end

  def handle_info(:configure, %{topology: topology} = state) when is_atom(topology) do
    :ets.new(topology, [:duplicate_bag, :named_table])

    {:noreply, state}
  end

  def handle_info({:delete!, key}, %{topology: topology} = state) when is_pid(key) do
    :ets.match(topology, {:"$1", key, :"_", :"_"})
    |> Enum.each(fn([key]) ->
      :ets.delete(topology, key)
    end)
    {:noreply, state}
  end

  def handle_info({:delete!, key}, %{topology: topology} = state) when is_tuple(key) do
    :ets.delete(topology, key)
    {:noreply, state}
  end

  def handle_info({:delete!, node}, %{topology: topology} = state) do
    :ets.match(topology, {:"$1", :"_", node, :"_"})
    |> Enum.each(fn([key]) ->
      :ets.delete(topology, key)
    end)
    {:noreply, state}
  end

  def handle_info({:register, routes}, state) when is_list(routes) do
    for route <- routes,
      do: send(self(), {:register, route})

    {:noreply, state}
  end

  def handle_info({:register, route}, %{topology: topology} = state) do
    :ets.insert(topology, {route.route, route.pid, route.node, route})

    send_topology_event(topology, {:begin_monitor, route})
    {:noreply, state}
  end

  def handle_call(:all, _from, %{topology: topology} = state) do
    routes = :ets.tab2list(topology)
    |> Enum.map(fn({_key, _pid, _node, route}) ->
      route
    end)
    {:reply, routes, state}
  end

  def handle_call({:lookup, route_key}, _from, %{topology: topology} = state) do
    result = case :ets.lookup(topology, route_key) do
               [] ->
                 {:error, "No matching routes"}
               routes ->
                 {_key, _pid, _node, route} = Enum.find(routes, fn({key, _pid, _node, _route}) -> key == route_key end)
                 {:ok, route}
             end

    {:reply, result, state}
  end

  defp send_topology_event(topology, event),
    do: events(topology) |> send(event)

  defp route_table_name(topology) when is_pid(topology),
    do: topology

  defp route_table_name(topology),
    do: :"#{topology}-route-table"

  defp events(topology),
    do: Application.get_env(:coyote, :topology_events, :"#{topology}-events")

end
