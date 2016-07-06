defmodule Coyote.Controller.Supervisor do
  use Supervisor

  @supervisor Coyote.Controller.Supervisor

  def start_link,
    do: Supervisor.start_link(__MODULE__, [], name: @supervisor)

  def init(_args),
    do: supervise(children, [strategy: :simple_one_for_one])

  def children,
    do: [Supervisor.Spec.worker(Coyote.RequestWorker, [], restart: :transient)]

  def start_child(mod, req),
    do: Supervisor.start_child(@supervisor, [mod, req])

end
