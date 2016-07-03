defmodule Coyote do
  use Application

  alias Coyote.Adaptors.Cowboy.Spec

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    routes = Coyote.Router.collect_routes |> build_routes

    children = [
      supervisor(Coyote.Adaptors.Cowboy.Supervisor, [%Spec{routes: routes}]),
      supervisor(Coyote.Request.Supervisor, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Coyote.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp build_routes([]), do: []
  defp build_routes([{route, mod}|rest]) do
    [{route, Coyote.Adaptors.Cowboy.Handler, [mod]}| build_routes(rest)]
  end
end


# Examples below

defmodule Home do
  use GenServer

  import Coyote.Router, [only: [routes: 1]]

  alias :cowboy_req, as: Request

  routes do
    [{"/", __MODULE__}]
  end

  def start_link,
    do: GenServer.start_link(__MODULE__, [])
  def start_link(req),
    do: GenServer.start_link(__MODULE__, req)

  def handle_call(:get, _from, req) do
    IO.inspect req
    Request.reply(200, [{"content-type", "text/html"}], "Hello World", req)

    {:reply, [], req}
  end
end

defmodule Company do
  use GenServer

  import Coyote.Router, [only: [routes: 1]]

  alias :cowboy_req, as: Request

  routes do
    [{"/company", __MODULE__}]
  end

  def start_link,
    do: GenServer.start_link(__MODULE__, [])
  def start_link(req),
    do: GenServer.start_link(__MODULE__, req)

  def handle_call(:get, _from, req) do
    IO.inspect req
    Request.reply(200, [{"content-type", "text/html"}], "Hello World from the Company page", req)

    {:reply, [], req}
  end
end
