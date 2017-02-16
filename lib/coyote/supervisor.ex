defmodule Coyote.Supervisor do
  use Supervisor

  @supervisor Coyote.Supervisor

  def start_link,
    do: Supervisor.start_link(__MODULE__, [], name: @supervisor)

  def init([]) do
    children = [
      supervisor(Coyote.Topology.Supervisor, [])
    ]
    supervise(children, strategy: :one_for_one)
  end
end
