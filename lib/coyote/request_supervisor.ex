defmodule Coyote.Request.Supervisor do
  use Supervisor

  def start_link,
    do: Supervisor.start_link(__MODULE__, nil, name: __MODULE__)

  def init(_opts),
    do: supervise(children, [strategy: :simple_one_for_one])

  defp children,
    do: [worker(Coyote.RequestWorker, [], restart: :transient)]

  def start_child(mod, req),
    do: Supervisor.start_child(__MODULE__, [mod, req])
end
