defmodule Coyote.Adaptors.Cowboy.Spec do
  defstruct scheme: :http,
    routes: [],
    opts: [port: 4000, acceptors: 100]
end

defmodule Coyote.Adaptors.Cowboy do
  use GenServer

  alias Coyote.Adaptors.Cowboy.Spec

  def start_link(args),
    do: GenServer.start_link(__MODULE__, args, name: __MODULE__)

  def init(args) do
    send(self, {:start_cowboy, args})
    {:ok, []}
  end

  def child_spec(scheme \\ :http, routes, [], opts \\ [port: 4000, acceptors: 100]),
    do: Supervisor.Spec.worker(__MODULE__, [%Spec{scheme: scheme, routes: routes, opts: opts}])

  def update_routes(routes) do
    GenServer.cast(__MODULE__, {:update_routes, routes})
  end

  def handle_info({:start_cowboy, args}, _state) do
    dispatch = :cowboy_router.compile([
      {:_, [{"/static/[...]", :cowboy_static, {:priv_dir, :coyote, "assets"}} | args.routes]}
    ])

    :cowboy.start_http(args.scheme, args.opts[:acceptors], [port: args.opts[:port]], [{:env, [{:dispatch, dispatch}]}])

    {:noreply, args}
  end

  def handle_cast({:update_routes, routes}, state) do
    routes = routes ++ state.routes

    dispatch = :cowboy_router.compile([
      {:_, [{"/static/[...]", :cowboy_static, {:priv_dir, :coyote, "assets"}} | routes]}
    ])

    :cowboy.set_env(state.scheme, :dispatch, dispatch)

    {:noreply, state}
  end
end
