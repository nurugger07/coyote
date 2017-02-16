defmodule Coyote.Topology do
  use Supervisor

  @moduledoc """

  Supervise the a topology named topology.

  """

  def start_link({:topology, topology}),
    do: Supervisor.start_link(__MODULE__, %{topology: topology}, name: topology)

  def init(opts) do
    children = [
      worker(Coyote.Topology.Events, [opts]),
      worker(Coyote.Topology.RouteTable, [opts]),
      worker(Coyote.Topology.Monitor, [opts])
    ]
    supervise(children, strategy: :one_for_one)
  end

end
