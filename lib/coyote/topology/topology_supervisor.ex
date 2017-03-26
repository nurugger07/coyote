defmodule Coyote.Topology.Supervisor do
  use Supervisor

  @moduledoc """

  Supervise multiple topologies

  """

  @supervisor Coyote.Topology.Supervisor

  def start_link,
    do: Supervisor.start_link(__MODULE__, [], name: @supervisor)

  def init([]) do
    children = [
      supervisor(Coyote.Topology, [], restart: :transient),
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

  @doc """
  Start a new topology with the given name. If the topology is already started
  return the pid.
  """
  def new_topology(topology) when is_atom(topology) do
    case Process.whereis(topology) do
      nil ->
        Supervisor.start_child(@supervisor, [topology: topology])
      pid ->
        {:ok, pid}
    end
  end
end
