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

  def handle_info({:start_cowboy, args}, state) do
    dispatch = :cowboy_router.compile([
      {:_, args.routes},
    ])

    :cowboy.start_http(args.scheme, args.opts[:acceptors], [port: args.opts[:port]], [{:env, [{:dispatch, dispatch}]}])

    {:noreply, state}
  end
end
