defmodule Coyote.Topology.EventsTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  setup do
    Application.put_env(:coyote, :routes_table, self())
    Application.put_env(:coyote, :monitor, self())

    {:ok, pid} = Coyote.Topology.Events.start_link(%{topology: "test"})

    on_exit fn() ->
      Application.delete_env(:coyote, :routes_table)
      Application.delete_env(:coyote, :monitor)
    end

    {:ok, %{event_manager: pid}}
  end

  test "sending message to remove routes forwards to routes table", %{event_manager: events} do
    send(events, {:remove_node_from_topology, :node_name})
    assert_receive {:delete!, :node_name}

    pid = self()

    send(events, {:remove_process_from_topology, pid})
    assert_receive {:delete!, ^pid}
  end

  test "sending message to begin monitoring route", %{event_manager: events} do
    pid = self()
    send(events, {:begin_monitor, %{pid: pid, node: :node_name}})
    assert_receive {:monitor_node, :node_name}
    assert_receive {:monitor_process, ^pid}
  end

  test "handle unknown events", %{event_manager: events} do
    message = fn() ->
      send(events, {:unknown_message, "foo"})
      :timer.sleep(100)
    end

    assert capture_log(message) =~ "Unknown message to Coyote.Topology.Events: {:unknown_message, \"foo\"}"
  end

end
