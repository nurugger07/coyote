defmodule Coyote.Topology.Monitor do
  use GenServer

  @moduledoc """

  Monitor Nodes & Process in the topology. When a node or process goes down the process sends a notification
  to topology events to handle the removal of routes from the routing table.

  """

  def start_link(%{topology: topology} = opts),
    do: GenServer.start_link(__MODULE__, opts, name: monitor_name(topology))

  def init(opts),
    do: {:ok, opts}

  def monitor_node(topology, node) do
    topology
    |> monitor_name()
    |> send({:monitor_node, node})
  end

  def monitor_process(topology, pid) do
    topology
    |> monitor_name()
    |> send({:monitor_process, pid})
  end

  def handle_info({:monitor_node, node}, state) do
    Node.monitor(node, true)
    {:noreply, state}
  end

  def handle_info({:monitor_process, pid}, state) do
    Process.monitor(pid)
    {:noreply, state}
  end

  def handle_info({:nodedown, node}, state) do
    state.topology
    |> events()
    |> send({:remove_node_from_topology, node})

    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, from_pid, _reason}, state) do
    state.topology
    |> events()
    |> send({:remove_process_from_topology, from_pid})

    {:noreply, state}
  end

  defp monitor_name(topology),
    do: :"#{topology}-monitor"

  defp events(topology),
    do: Application.get_env(:coyote, :topology_events, :"#{topology}-events")

end
