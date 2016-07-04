defmodule MyApp.Supervisor do
  use Supervisor
  use Coyote.Router

  routes do
    [
      {"/", MyApp.Home},
      {"/company", MyApp.Company},
      {"/company/:id", MyApp.Company},
      {"/company/:id/edit", MyApp.Company}
    ]
  end

  def start_link,
    do: Supervisor.start_link(__MODULE__, [], name: __MODULE__)

  def init(_opts),
    do: supervise(children, [strategy: :one_for_one])

  def children do
    [
      worker(MyApp.Home, [], restart: :permanent),
      worker(MyApp.Company, [], restart: :permanent)
    ]
  end
end

defmodule MyApp.Home do
  use GenServer

  alias :cowboy_req, as: Request

  def start_link,
    do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def init(_opts),
    do: {:ok, nil}

  def handle_call({:get, []}, _from, state) do
    {:reply, {200, [{"content-type", "text/html"}], "Hello World"}, state}
  end

end

defmodule MyApp.Company do
  use GenServer

  alias :cowboy_req, as: Request

  def start_link,
    do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def init(_opts),
    do: {:ok, nil}

  def handle_call({:get, []}, _from, state) do
    {:reply, {200, [{"content-type", "text/html"}], "Hello World from the company"}, state}
  end

  def handle_call({:get, [id: id]}, _from, state) do
    {:reply, {200, [{"content-type", "text/html"}], "Hello World from the company #{id}"}, state}
  end
end
