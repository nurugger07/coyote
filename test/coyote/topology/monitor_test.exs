defmodule Coyote.Topology.MonitorTest do
  use ExUnit.Case

  alias Coyote.Topology.Monitor

  @meta_data %{topology: "monitor-test"}

  setup do
    Application.put_env(:coyote, :topology_events, self())

    Monitor.start_link(@meta_data)

    on_exit fn ->
      Application.delete_env(:coyote, :topology_events)
    end

    {:ok, @meta_data}
  end

  test "monitor node and send event when down", %{topology: topology} do
    {:ok, _node} = Node.start(:monitor_test, :shortnames)

    Monitor.monitor_node(topology, :monitor_test)
    Node.stop
    assert_receive {:remove_node_from_topology, :monitor_test}
  end

  test "monitor process and send event when down", %{topology: topology} do
    pid = Process.spawn(fn() -> :timer.sleep(10) end, [])

    Monitor.monitor_process(topology, pid)
    assert_receive {:remove_process_from_topology, ^pid}
  end
end
