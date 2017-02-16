defmodule Coyote.Topology.Events do
  use GenServer

  @moduledoc """
  Handle events for topology
  """

  require Logger

  def start_link(%{topology: topology} = opts),
    do: GenServer.start_link(__MODULE__, opts, name: :"#{topology}-events")

  def init(opts),
    do: {:ok, opts}

  def handle_info({:remove_node_routes, node}, state) do
    state.topology
    |> route_table
    |> send({:delete!, node})
    {:noreply, state}
  end

  def handle_info({:remove_process_routes, pid}, state) do
    state.topology
    |> route_table
    |> send({:delete!, pid})
    {:noreply, state}
  end

  def handle_info({:begin_monitor, route}, state) do
    m = monitor(state.topology)

    send(m, {:monitor_node, route.node})
    send(m, {:monitor_process, route.pid})
    {:noreply, state}
  end

  def handle_info(unknown, state) do
    Logger.warn("Unknown message: #{inspect unknown}")
    {:noreply, state}
  end

  defp route_table(topology),
    do: Application.get_env(:coyote, :routes_table, :"#{topology}-route-table")

  defp monitor(topology),
    do: Application.get_env(:coyote, :monitor, :"#{topology}-monitor")

end
