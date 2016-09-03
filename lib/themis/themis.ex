defmodule Themis do
  use Application

  def start(_type, _args) do
    Coyote.start([], [])

    Themis.Supervisor.start_link

    Themis.Page.publish_routes
  end

end

defmodule Themis.Supervisor do
  use Supervisor

  def start_link,
    do: Supervisor.start_link(__MODULE__, [], name: __MODULE__)

  def init(_opts),
    do: supervise(children, [strategy: :one_for_one])

  def children do
    [
      worker(Themis.Page, [], restart: :permanent)
    ]
  end
end
